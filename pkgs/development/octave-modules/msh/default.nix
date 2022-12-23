{ buildOctavePackage
, lib
, fetchurl
# Octave Dependencies
, splines
# Other Dependencies
, gmsh
, gawk
, pkg-config
, dolfin
, autoconf, automake
}:

buildOctavePackage rec {
  pname = "msh";
  version = "1.0.12";

  src = fetchurl {
    url = "mirror://sourceforge/octave/${pname}-${version}.tar.gz";
    sha256 = "sha256-7xbB+RXq5SE7Ke5rNwSo/mqdSZTzCLXRhS4zdfGz55s=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf automake
    dolfin
  ];

  buildInputs = [
    dolfin
  ];

  propagatedBuildInputs = [
    gmsh
    gawk
    dolfin
  ];

  requiredOctavePackages = [
    splines
  ];

  meta = with lib; {
    homepage = "https://octave.sourceforge.io/msh/index.html";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ KarlJoad ];
    description = "Create and manage triangular and tetrahedral meshes for Finite Element or Finite Volume PDE solvers";
    longDescription = ''
      Create and manage triangular and tetrahedral meshes for Finite Element or
      Finite Volume PDE solvers. Use a mesh data structure compatible with
      PDEtool. Rely on gmsh for unstructured mesh generation.
    '';
    # Not technically broken, but missing some functionality.
    # dolfin needs to be its own stand-alone library for the last tests to pass.
  };
}
