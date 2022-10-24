FROM gitpod/workspace-full

LABEL org.opencontainers.image.title="xsrepod"
LABEL org.opencontainers.image.description="Turbocharged Gitpod Workspace image, forked from gitpod/workspace-full."
LABEL org.opencontainers.image.author="sysrex <alex@sysrex.com>"
LABEL org.opencontainers.image.source="https://github.com/xsre/xsrepod"
LABEL org.opencontainers.image.license="MIT"
LABEL repository="https://github.com/xsre/xsrepod"
LABEL maintainer="sysrex"

WORKDIR /home/gitpod

# update system packages and cleanup cache
ARG DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get -y update && sudo apt-get -y upgrade && sudo rm -rf /var/lib/apt/lists/*

USER gitpod

# update/upgrade/cleanup homebrew packages
RUN brew update && brew upgrade && brew cleanup

# copy a couple files needed for the next couple steps
COPY --chown=gitpod:gitpod [ ".tarignore", ".Brewfile", "/home/gitpod/" ]

# pull down and extract sysrex/dotfiles with curl + tar
RUN curl -fsSL "https://github.com/sysrex/dotfiles/archive/main.tar.gz" | \
    tar -xz -C "$HOME" --overwrite -X ~/.tarignore --wildcards --anchored \
    --ignore-case --exclude-backups --exclude-vcs --backup=existing --totals \
    --strip-components=1 -o --owner=gitpod --group=gitpod ;

# clean some things up with .gitconfig and .gitignore
RUN cat "$HOME/gitconfig" >> "$HOME/.gitconfig" && \
    rm -f "$HOME/gitconfig" "$HOME/.gitignore" "$HOME/.profile" &>/dev/null; \
    mv -f "$HOME/gitignore" "$HOME/.gitignore" &>/dev/null; \
    # fix unsafe permissions on .gnupg folder
    chmod 700 "$HOME/.gnupg";

# install the homebrew packages from ~/.Brewfile
RUN brew bundle install --global --no-lock && \
    # show success message if all goes well
    echo -e "\n\e[1;92;7m SUCCESS! \e[0;1;3;92m gitpod-enhanced setup completed \e[0m\n";