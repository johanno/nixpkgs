{ system ? builtins.currentSystem
, pkgs ? import ../../.. { inherit system; }
}:
{
  # Run a single node k3s cluster and verify a pod can run
  single-node = import ./single-node.nix { inherit system pkgs; };
}
