{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [ "aarch64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "maven-project";
            version = "1.0";

            src = ./.;  # Point to your project source directory

            nativeBuildInputs = [
              pkgs.maven
            ];

            buildInputs = [
              pkgs.jdk
            ];

            installPhase = ''
              mkdir -p $out/bin
              cp -r * $out

              # Create a wrapper script to run Maven with arguments
              cat > $out/bin/run-maven <<EOF
              #!/bin/sh
              exec ${pkgs.maven}/bin/mvn "\$@"
              EOF
              chmod +x $out/bin/run-maven
            '';

            meta = {
              description = "A Maven project environment";
            };
          };
        };
         apps = {
          default = {
            type = "app";
            program = "${self'.packages.default}/bin/run-maven";
            # Pass arguments to `mvn`
          };
        };
        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.jdk pkgs.jdt-language-server
            pkgs.maven
          ];
        };

      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
