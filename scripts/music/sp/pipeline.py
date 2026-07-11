#!/usr/bin/env python3
"""
Pipeline completo:
1. Extrae metadata útil desde un JSON de Spotify con jq.
2. Busca cada canción en YouTube con yt-dlp.
3. Descarga WAV.
4. Convierte a Opus con metadata, cover y ReplayGain.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from dataclasses import dataclass
from pathlib import Path


JQ_FILTER = r'''
.items[]
| (.track? // .item?) as $track
| select($track != null and $track.type == "track")
| [
    ($track.name // ""),
    (($track.artists // []) | map(.name) | join(", ")),
    ($track.album.name // ""),
    ($track.album.images[0].url // "")
  ]
| @tsv
'''

SILENCE_FILTER = (
    "silenceremove=start_periods=1:start_silence=1.5:start_threshold=-30dB,"
    "areverse,"
    "silenceremove=start_periods=1:start_silence=1.5:start_threshold=-30dB,"
    "areverse"
)


@dataclass(frozen=True)
class Track:
    title: str
    artist: str
    album: str
    cover_url: str


def run(cmd: list[str], *, quiet: bool = False) -> subprocess.CompletedProcess[str]:
    stdout = subprocess.PIPE if quiet else None
    stderr = subprocess.PIPE if quiet else None
    return subprocess.run(
        cmd,
        check=True,
        text=True,
        stdout=stdout,
        stderr=stderr,
    )


def require_commands(commands: list[str]) -> None:
    missing = [cmd for cmd in commands if shutil.which(cmd) is None]
    if missing:
        print(f"Faltan dependencias: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)


def playlist_url(value: str) -> str:
    if value.startswith(("http://", "https://")):
        return value
    return f"https://open.spotify.com/playlist/{value}"


def playlist_id(value: str) -> str:
    match = re.search(r"playlist/([^?/#]+)", value)
    if match:
        return match.group(1)
    return value


def sanitize_filename(value: str) -> str:
    value = re.sub(r'[/\\:*?"<>|]', "_", value)
    value = re.sub(r"\s+", " ", value).strip()
    return value or "unknown"


def normalize_text(value: str) -> str:
    value = value.casefold()
    value = re.sub(r"[^a-z0-9]+", " ", value)
    return re.sub(r"\s+", " ", value).strip()


def search_queries(track: Track) -> list[str]:
    clean_title = re.sub(r"[^\w\s-]", " ", track.title, flags=re.UNICODE)
    clean_artist = re.sub(r"[^\w\s-]", " ", track.artist, flags=re.UNICODE)
    clean_title = re.sub(r"\s+", " ", clean_title).strip()
    clean_artist = re.sub(r"\s+", " ", clean_artist).strip()

    candidates = [
        f"{track.artist} {track.title}",
        f"{track.title} {track.artist}",
        f"{clean_artist} {clean_title}",
        f"{clean_artist} {clean_title} audio",
        f"{clean_artist} {clean_title} official",
        normalize_text(f"{track.artist} {track.title}"),
        normalize_text(f"{track.title} {track.artist}"),
    ]

    seen: set[str] = set()
    queries: list[str] = []
    for query in candidates:
        query = re.sub(r"\s+", " ", query).strip()
        if query and query not in seen:
            seen.add(query)
            queries.append(query)

    return queries


def cookie_args() -> list[str]:
    cookie_file = Path("./cookies.txt")
    return ["--cookies", str(cookie_file)] if cookie_file.is_file() else []


def find_existing_wav(track: Track, wav_dir: Path, index: int, fallback_offset: int) -> Path | None:
    safe_artist = sanitize_filename(track.artist)
    safe_title = sanitize_filename(track.title)
    expected = wav_dir / f"{index:02d} - {safe_artist} - {safe_title}.wav"

    if expected.exists() and expected.stat().st_size > 0:
        return expected

    wavs = sorted(wav_dir.glob("*.wav"))
    if not wavs:
        return None

    title_tokens = normalize_text(track.title).split()
    artist_tokens = normalize_text(track.artist).split()

    for wav in wavs:
        name = normalize_text(wav.name)
        if title_tokens and all(token in name for token in title_tokens):
            return wav

    for wav in wavs:
        name = normalize_text(wav.name)
        score = sum(
            1 for token in [*title_tokens, *artist_tokens] if len(token) >= 4 and token in name
        )
        if score >= 2:
            return wav

    if fallback_offset < len(wavs):
        return wavs[fallback_offset]

    return None


def extract_tracks_with_jq(json_file: Path) -> list[Track]:
    result = run(["jq", "-r", JQ_FILTER, str(json_file)], quiet=True)
    tracks: list[Track] = []

    reader = csv.reader(result.stdout.splitlines(), delimiter="\t")
    for row in reader:
        if len(row) < 4:
            continue

        title, artist, album, cover_url = row[:4]
        if title and artist:
            tracks.append(Track(title, artist, album, cover_url))

    return tracks


def artist_names(value: object) -> str:
    if isinstance(value, list):
        names: list[str] = []
        for item in value:
            if isinstance(item, str):
                names.append(item)
            elif isinstance(item, dict):
                name = item.get("name")
                if isinstance(name, str):
                    names.append(name)
        return ", ".join(name for name in names if name)

    if isinstance(value, str):
        return value

    return ""


def first_string(mapping: dict[str, object], keys: list[str]) -> str:
    for key in keys:
        value = mapping.get(key)
        if isinstance(value, str):
            return value
    return ""


def extract_spotdl_items(payload: object) -> list[dict[str, object]]:
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]

    if isinstance(payload, dict):
        for key in ("songs", "tracks", "items"):
            value = payload.get(key)
            if isinstance(value, list):
                return [item for item in value if isinstance(item, dict)]

    return []


def extract_tracks_from_spotdl(spotdl_file: Path) -> list[Track]:
    with spotdl_file.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)

    tracks: list[Track] = []
    for item in extract_spotdl_items(payload):
        title = first_string(item, ["name", "title", "song_name"])
        artist = artist_names(item.get("artists") or item.get("artist"))
        album = first_string(item, ["album_name", "album", "album_title"])
        cover_url = first_string(item, ["cover_url", "cover", "thumbnail", "image"])

        if title and artist:
            tracks.append(Track(title, artist, album, cover_url))

    return tracks


def save_playlist_with_spotdl(playlist: str, spotdl_file: Path) -> None:
    spotdl_file.parent.mkdir(parents=True, exist_ok=True)
    run(
        [
            "spotdl",
            "save",
            playlist_url(playlist),
            "--save-file",
            str(spotdl_file),
        ]
    )


def write_metadata_file(tracks: list[Track], metadata_file: Path) -> None:
    metadata_file.parent.mkdir(parents=True, exist_ok=True)
    with metadata_file.open("w", encoding="utf-8", newline="") as handle:
        for track in tracks:
            handle.write(
                f"{track.title}|{track.artist}|{track.album}|{track.cover_url}\n"
            )


def download_cover(track: Track, tmp_dir: Path) -> Path | None:
    if not track.cover_url:
        return None

    cover = tmp_dir / "cover.jpg"
    try:
        urllib.request.urlretrieve(track.cover_url, cover)
    except Exception:
        return None

    return cover if cover.exists() and cover.stat().st_size > 0 else None


def download_wav(track: Track, wav_dir: Path, index: int) -> Path | None:
    safe_artist = sanitize_filename(track.artist)
    safe_title = sanitize_filename(track.title)
    output_wav = wav_dir / f"{index:02d} - {safe_artist} - {safe_title}.wav"

    if output_wav.exists() and output_wav.stat().st_size > 0:
        print(f"[=] WAV existe: {output_wav}")
        return output_wav

    with tempfile.TemporaryDirectory(prefix="sp-dl-") as tmp:
        tmp_dir = Path(tmp)
        tried_queries: list[str] = []
        downloaded: list[Path] = []

        for attempt, query in enumerate(search_queries(track), start=1):
            tried_queries.append(query)
            print(f"[↓] Buscando y descargando ({attempt}): {query}")

            for old_file in tmp_dir.iterdir():
                if old_file.is_file():
                    old_file.unlink()

            cmd = [
                "yt-dlp",
                *cookie_args(),
                "-P",
                str(tmp_dir),
                "-o",
                "source.%(ext)s",
                "-f",
                "bestaudio/best",
                "--no-playlist",
                f"ytsearch1:{query}",
            ]

            try:
                run(cmd)
            except subprocess.CalledProcessError:
                continue

            downloaded = [
                path
                for path in sorted(tmp_dir.iterdir())
                if path.is_file() and path.suffix.lower() not in {".part", ".ytdl"}
            ]
            if downloaded:
                break

        if not downloaded:
            print(
                f"[!] yt-dlp no encontró audio para: {track.artist} - {track.title}",
                file=sys.stderr,
            )
            print("    Queries probadas:", file=sys.stderr)
            for tried_query in tried_queries:
                print(f"    - {tried_query}", file=sys.stderr)
            return None

        wav_dir.mkdir(parents=True, exist_ok=True)
        try:
            run(
                [
                    "ffmpeg",
                    "-v",
                    "warning",
                    "-y",
                    "-i",
                    str(downloaded[0]),
                    "-c:a",
                    "pcm_s16le",
                    "-ar",
                    "44100",
                    "-ac",
                    "2",
                    str(output_wav),
                ]
            )
        except subprocess.CalledProcessError:
            files = ", ".join(path.name for path in downloaded) or "(ninguno)"
            print(f"[!] ffmpeg no pudo convertir audio para: {query}", file=sys.stderr)
            print(f"    Archivos temporales detectados: {files}", file=sys.stderr)
            output_wav.unlink(missing_ok=True)
            return None

        return output_wav


def encode_opus(track: Track, wav_file: Path, opus_dir: Path, index: int) -> Path | None:
    safe_artist = sanitize_filename(track.artist)
    safe_title = sanitize_filename(track.title)
    output_opus = opus_dir / f"{index:02d} - {safe_artist} - {safe_title}.opus"

    if output_opus.exists() and output_opus.stat().st_size > 0:
        print(f"[=] Opus existe: {output_opus}")
        return output_opus

    opus_dir.mkdir(parents=True, exist_ok=True)
    print(f"[→] Codificando: {output_opus.name}")

    with tempfile.TemporaryDirectory(prefix="sp-encode-") as tmp:
        tmp_dir = Path(tmp)
        tmp_wav = tmp_dir / "trimmed.wav"
        cover = download_cover(track, tmp_dir)

        try:
            run(
                [
                    "ffmpeg",
                    "-v",
                    "warning",
                    "-y",
                    "-i",
                    str(wav_file),
                    "-af",
                    SILENCE_FILTER,
                    "-c:a",
                    "pcm_s16le",
                    "-ar",
                    "44100",
                    "-ac",
                    "2",
                    str(tmp_wav),
                ]
            )

            opus_cmd = [
                "opusenc",
                "--title",
                track.title,
                "--artist",
                track.artist,
                "--album",
                track.album,
                "--bitrate",
                "320",
                "--vbr",
            ]
            if cover:
                opus_cmd.extend(["--picture", str(cover)])
            opus_cmd.extend([str(tmp_wav), str(output_opus)])
            run(opus_cmd)

            try:
                run(["rsgain", "custom", "-s", "i", "-l", "-18", "-o", "t", str(output_opus)])
            except subprocess.CalledProcessError:
                print(f"[!] ReplayGain falló: {output_opus}", file=sys.stderr)

            return output_opus
        except subprocess.CalledProcessError:
            print(f"[!] Falló el encode: {track.artist} - {track.title}", file=sys.stderr)
            output_opus.unlink(missing_ok=True)
            return None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convierte una playlist de Spotify en metadata, WAV y Opus."
    )
    parser.add_argument(
        "playlist",
        help="Código/id de playlist de Spotify. También acepta URL o archivo JSON/.spotdl.",
    )
    parser.add_argument(
        "-n",
        "--name",
        help="Nombre de playlist/subcarpeta. Por defecto usa el código o nombre del archivo.",
    )
    parser.add_argument(
        "--base-dir",
        type=Path,
        default=Path(os.environ.get("SP_BASE_DIR", "~/Music/spotify_playlists")).expanduser(),
        help="Directorio base. Default: $SP_BASE_DIR o ~/Music/spotify_playlists",
    )
    parser.add_argument(
        "--start",
        type=int,
        default=1,
        help="Número inicial para los archivos de salida. Default: 1",
    )
    parser.add_argument(
        "--limit",
        type=int,
        help="Procesa solo las primeras N canciones útiles.",
    )
    parser.add_argument(
        "--metadata-only",
        action="store_true",
        help="Solo extrae metadata con jq y escribe el .txt.",
    )
    parser.add_argument(
        "--skip-download",
        action="store_true",
        help="No descarga si ya tienes WAV con el nombre esperado.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    input_path = Path(args.playlist).expanduser()
    default_name = input_path.stem if input_path.is_file() else playlist_id(args.playlist)
    playlist_name = sanitize_filename(args.name or default_name)

    if input_path.is_file() and input_path.suffix == ".json":
        require_commands(["jq"])
    elif not input_path.is_file():
        require_commands(["spotdl"])

    if not args.metadata_only:
        require_commands(["yt-dlp", "ffmpeg", "opusenc", "rsgain"])

    metadata_file = args.base_dir / "data" / f"{playlist_name}.txt"
    spotdl_file = args.base_dir / "data" / f"{playlist_name}.spotdl"
    wav_dir = args.base_dir / "music" / "wav" / playlist_name
    opus_dir = args.base_dir / "music" / "opus" / playlist_name

    if input_path.is_file() and input_path.suffix == ".json":
        tracks = extract_tracks_with_jq(input_path)
    elif input_path.is_file() and input_path.suffix == ".spotdl":
        tracks = extract_tracks_from_spotdl(input_path)
    else:
        save_playlist_with_spotdl(args.playlist, spotdl_file)
        tracks = extract_tracks_from_spotdl(spotdl_file)

    if args.limit:
        tracks = tracks[: args.limit]

    if not tracks:
        print("No encontré tracks útiles en el JSON.", file=sys.stderr)
        return 1

    write_metadata_file(tracks, metadata_file)
    print(f"[✓] Metadata: {metadata_file}")

    if args.metadata_only:
        return 0

    for offset, track in enumerate(tracks):
        index = args.start + offset

        if args.skip_download:
            wav_file = find_existing_wav(track, wav_dir, index, offset)
        else:
            wav_file = download_wav(track, wav_dir, index)

        if wav_file and wav_file.exists():
            encode_opus(track, wav_file, opus_dir, index)
        else:
            print(f"[!] Sin WAV, omito encode: {track.artist} - {track.title}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
