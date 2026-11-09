{
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"; 
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix"; 
  }; 

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, ...}@inputs: 
  let system = "x86_64-linux"; in { 
    nixosConfigurations.repono = nixpkgs.lib.nixosSystem { 
      inherit system;
      specialArgs = { 
        pkgs-unstable = import nixpkgs-unstable { 
          inherit system; 
          config.allowUnfree = true; 
        }; 
      }; 
      modules = [ 
        ./hosts/repono
        sops-nix.nixosModules.sops
      ]; 
    }; 
  };
} 
