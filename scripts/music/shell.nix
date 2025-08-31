
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.yt-dlp
    pkgs.opusTools
    pkgs.r128gain
  ];

  shellHook = ''
    echo "🌟 Entorno listo: yt-dlp, opus-tools y r128gain disponibles"
  '';
}
