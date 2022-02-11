{ lib
, buildPythonPackage
, fetchPypi
, setuptools-scm
, pyyaml
, callPackage
, hcloud
}:

buildPythonPackage rec {
  pname = "molecule-hetznercloud";
  version = "1.3.0";
  format = "pyproject";
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-hpHsalxSD/EflJRKl7n7P9vVwhywnuJ10X6AavAmJPU=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace 'pyyaml >= 5.3.1, < 6' 'pyyaml'
  '';
  
  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    ansible-compat
    pyyaml
    molecule
    hcloud
  ];

  pythonImportsCheck = [ "molecule_hetznercloud" ];
  
  meta = with lib; {
    description = "Molecule Hetzner Driver allows molecule users to test Ansible code using hcloud vps";
    homepage = "https://github.com/ansible-community/molecule-hetznercloud";
    license = licenses.mit;
    maintainers = with maintainers; [ heph2 ];
  };
}
