{
  description = "Spotify playlist audio tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              curl
              ffmpeg-headless
              jq
              opus-tools
              python3
              rsgain
              spotdl
              yt-dlp
            ];

            shellHook = ''
              echo "Entorno listo: spotdl, yt-dlp, ffmpeg, jq, opus-tools, rsgain y python3 disponibles"
            '';
          };
        });
    };
}
