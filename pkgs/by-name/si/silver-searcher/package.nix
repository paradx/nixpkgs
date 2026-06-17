{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  pcre2,
  zlib,
  xz,
}:

stdenv.mkDerivation rec {
  pname = "silver-searcher";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "silver_searcher";
    repo = "silver-searcher-ng";
    rev = version;
    sha256 = "";
  };

  patches = [ ./bash-completion.patch ];

  # Workaround build failure on -fno-common toolchains like upstream
  # gcc-10. Otherwise build fails as:
  #   ld: src/zfile.o:/build/source/src/log.h:12: multiple definition of
  #     `print_mtx'; src/ignore.o:/build/source/src/log.h:12: first defined here
  # TODO: remove once next release has https://github.com/ggreer/the_silver_searcher/pull/1377
  env.NIX_CFLAGS_COMPILE = "-fcommon";
  NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isLinux "-lgcc_s";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [
    pcre2
    zlib
    xz
  ];

  meta = {
    homepage = "https://github.com/silver-searcher/silver-searcher-ng/";
    description = "Code-searching tool similar to ack, but faster";
    maintainers = with lib.maintainers; [ paradx ];
    mainProgram = "ag";
    platforms = lib.platforms.all;
    license = lib.licenses.asl20;
  };
}
