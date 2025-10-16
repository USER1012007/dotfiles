
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.yt-dlp
    pkgs.opusTools
    pkgs.rsgain
  ];

  shellHook = ''
    echo "🌟 Entorno listo: yt-dlp, opus-tools y rsgain disponibles"
  '';
}
