{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, bison
, libevent
, libressl
, ncurses
, autoreconfHook
, buildPackages
}:

stdenv.mkDerivation rec {
  pname = "telescope";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = "19b1c23de9222d72aa0c57e00fdd9c3d01bcd485";
    sha256 = "P/nixtQi0ae8fsdpTr25E7SxfrzFJW5kN7i/ZF4whio=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
  ];

  buildInputs = [
    libevent
    libressl
    ncurses
  ];

  configureFlags = [
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
  ];

  meta = with lib; {
    description = "Telescope is a w3m-like browser for Gemini";
    homepage = "https://telescope.omarpolo.com/";
    license = licenses.isc;
    maintainers = with maintainers; [ heph2 ];
    platforms = platforms.unix;
  };
}
