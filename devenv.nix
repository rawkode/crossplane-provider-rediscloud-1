{ pkgs, lib, config, inputs, ... }:
{
  languages.go.enable = true;
  
  # Python configuration with venv and uv
  languages.python = {
    enable = true;
    venv.enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  packages = with pkgs; [
    # Building
    curl
    git
    gnumake
    go-tools
    jq
    unzip

    # Linting
    golangci-lint

    # Testing
    kind
    kubectl
    kubernetes-helm
    podman
  ];
}
