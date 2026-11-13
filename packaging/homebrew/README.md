# Publishing vigcipher with Homebrew

`vigcipher.rb` is the formula. It lives here so it is versioned with the
code, but Homebrew installs it from a separate *tap* repository named
`RedRoosterKey/homebrew-tap`. Users then run:

```bash
brew install redroosterkey/tap/vigcipher
```

## First release

1. Tag the release and push the tag. GitHub serves a source tarball for
   every tag automatically.

   ```bash
   git tag -a v0.0.5 -m "vigcipher 0.0.5"
   git push origin v0.0.5
   ```

   Optionally turn it into a GitHub Release with notes:

   ```bash
   gh release create v0.0.5 --generate-notes
   ```

2. Get the tarball's checksum and put it in `sha256` in `vigcipher.rb`:

   ```bash
   curl -sL https://github.com/RedRoosterKey/vigcipher/archive/refs/tags/v0.0.5.tar.gz | shasum -a 256
   ```

3. Create the tap locally. `brew tap-new` scaffolds a repository with
   GitHub Actions that test the formula and build bottles (prebuilt
   binaries) on every pull request.

   ```bash
   brew tap-new redroosterkey/tap
   cp packaging/homebrew/vigcipher.rb "$(brew --repository redroosterkey/tap)/Formula/"
   ```

4. Check that it builds, passes its test, and is clean:

   ```bash
   brew install --build-from-source redroosterkey/tap/vigcipher
   brew test redroosterkey/tap/vigcipher
   brew audit --strict --new redroosterkey/tap/vigcipher
   ```

5. Publish the tap on GitHub:

   ```bash
   cd "$(brew --repository redroosterkey/tap)"
   git add Formula/vigcipher.rb && git commit -m "vigcipher 0.0.5"
   gh repo create RedRoosterKey/homebrew-tap --public --source . --push
   ```

## Later releases

Bump `version.h`, tag `vX.Y.Z`, push the tag, then update `url` and
`sha256` in the tap (and here). `brew bump-formula-pr` can do the edit and
open the pull request for you:

```bash
brew bump-formula-pr --url=https://github.com/RedRoosterKey/vigcipher/archive/refs/tags/vX.Y.Z.tar.gz redroosterkey/tap/vigcipher
```

## homebrew-core

Once the project is better known (Homebrew's rough bar is 75+ stars, or
30+ forks or watchers), the same formula can be submitted to
`Homebrew/homebrew-core` so that a plain `brew install vigcipher` works.
