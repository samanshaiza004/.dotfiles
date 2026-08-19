{
	inputs = {

		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		mango = {
			url = "github:mangowm/mango";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};



	outputs = { self, nixpkgs, mango, home-manager, ... }@inputs: {
		nixosConfigurations.saman = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";

			specialArgs = { inherit inputs; };

			modules = [
				./hosts/desktop/configuration.nix
				mango.nixosModules.mango
			];
		};
	};
}
