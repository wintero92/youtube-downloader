{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.ffmpeg_7
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.yt-dlp
  ];

  shellHook = ''
  '';
}