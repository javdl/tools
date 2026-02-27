{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      prekVersion = "0.3.3";
      prekHashes = {
        "x86_64-linux" = "sha256-RPYzZ6h/zqvoYrByNARmRc4SFAix7Y6nquANClQMonE=";
        "x86_64-darwin" = "sha256-C2VVXSvSrdaySh8r5Rz+5tDIN4klYLrywhY72vr+0zg=";
        "aarch64-linux" = "sha256-hckriLkcvhVIouYWMq8ASgnH8rtHXANzy7DFI6hI4gQ=";
        "aarch64-darwin" = "sha256-EsHigdTUhOqm1QKATGqMd6sG8f3SLF/UbAL4euXzwa8=";
      };
      prekTargets = {
        "x86_64-linux" = "x86_64-unknown-linux-gnu";
        "x86_64-darwin" = "x86_64-apple-darwin";
        "aarch64-linux" = "aarch64-unknown-linux-gnu";
        "aarch64-darwin" = "aarch64-apple-darwin";
      };
    in
    {
      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            prek = pkgs.stdenv.mkDerivation {
              pname = "prek";
              version = prekVersion;
              src = pkgs.fetchurl {
                url = "https://github.com/j178/prek/releases/download/v${prekVersion}/prek-${prekTargets.${system}}.tar.gz";
                hash = prekHashes.${system};
              };
              sourceRoot = ".";
              installPhase = ''
                mkdir -p $out/bin
                cp prek-${prekTargets.${system}}/prek $out/bin/
                chmod +x $out/bin/prek
              '';
              meta = {
                description = "Better pre-commit, re-engineered in Rust";
                homepage = "https://github.com/j178/prek";
                license = pkgs.lib.licenses.mit;
              };
            };
          in
          {
            default = pkgs.mkShell {
              buildInputs = [
                prek
                pkgs.nodejs_22
                pkgs.python3
              ];

              shellHook = ''
                prek install
              '';
            };
          });
    };
}
