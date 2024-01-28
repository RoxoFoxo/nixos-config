{
  inputs = {
    nixpkgs_stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    # nixpkgs_stable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home_manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs_stable";
    };
    nixjail = {
      url = "github:shiryel/nixjail/master";
      inputs.nixpkgs.follows = "nixpkgs_stable";
    };
    neovim.url = "github:shiryel/nvim/master";
  };

  outputs = { self, nixpkgs_stable, nixpkgs_unstable, home_manager, ... }@inputs:
    let
      pkgs_unstable = import nixpkgs_unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      pkgs = import nixpkgs_stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      lib = nixpkgs_stable.lib;
    in
    {
      nixosConfigurations.desktop = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit pkgs_unstable; };
        lib = lib;
        modules = [
          ./system/configuration.nix

          # Home Manager
          # https://rycee.gitlab.io/home-manager/
          home_manager.nixosModules.home-manager
          {
            home-manager.users = {
              roxo.imports = [ ./home_manager/roxo.nix ];
            };
            home-manager.extraSpecialArgs = { inherit pkgs pkgs_unstable; };
            # use the pkgs from nixpkgs system
            home-manager.useGlobalPkgs = true;
            # install packages to /etc/profiles instead of $HOME/.nix-profile
            home-manager.useUserPackages = true;
          }
          inputs.nixjail.nixosModules.nixjail
        ] ++ inputs.neovim.nixosModules.neovim;
      };
    };
}
