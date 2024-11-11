{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mach-nix.url = "github:davhau/mach-nix";
  };

  outputs = inputs@{ flake-parts, mach-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = [ "aarch64-darwin" "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        mach = inputs.mach-nix.lib.${system};
        pythonVersion = "python310";  # Specify the Python version from nixpkgs

        pythonEnv = mach.mkPython {
          python = pythonVersion;
          requirements = builtins.readFile ./requirements.txt;
        };
        in 
        {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "python-project";
            version = "1.0";
            src = ./.;
            interpreter = pythonEnv;
            installPhase = ''
              mkdir -p $out/bin
              cp -r * $out
              cat > $out/bin/run-python <<EOF
              #!/bin/sh
              exec ${pythonEnv}/bin/python "\$@"
              EOF
              chmod +x $out/bin/run-python
            '';

            meta = {
              description = "A python project environment";
            };
          };
        };
         apps = {
          default = {
            type = "app";
            program = "${self'.packages.default}/bin/run-python";
          };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
          ];
        };

      };
      flake = {};
    };
}
