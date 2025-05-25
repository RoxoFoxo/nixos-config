{
  inputs = {
    nixpkgs_stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home_manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs_stable";
    };
    nixjail = {
      url = "github:shiryel/nixjail/master";
      inputs.nixpkgs.follows = "nixpkgs_stable";
    };
    # neovim.url = "git+file:/home/roxo/Programming/nvim";
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
          ({ pkgs_unstable, ... }: {
            nixpkgs.overlays = lib.mkBefore [ (p: f: { neovim = pkgs_unstable.neovim; }) ];
          })


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
