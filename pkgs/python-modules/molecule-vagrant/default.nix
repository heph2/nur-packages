{ lib
, buildPythonPackage
, fetchPypi
, setuptools-scm
, pyyaml
, jinja2
, python-vagrant
, selinux-python
}:

buildPythonPackage rec {
  pname = "molecule-vagrant";
  version = "1.0.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-/B6YgUciatqCiEdbdoxSo3NmyLUNMLkWNcrPxk4UaMM=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    pyyaml
    molecule
    hcloud
    jinja2
    python-vagrant
    selinux-python
  ];

  pythonImportsCheck = [ "molecule_vagrant" ];

  meta = with lib; {
    description = "Molecule Vagrant Driver allows molecule users to test Ansible code using vagrant";
    homepage = "https://github.com/ansible-community/molecule-vagrant";
    license = license.mit;
    maintainers = with maintainers; [ heph2 ];
  };
}
