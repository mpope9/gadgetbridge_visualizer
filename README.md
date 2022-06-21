# GadgetbridgeVisualizer

Gadgetbridge Visualizer is a companion web-application for the [Gadgetbridge](https://codeberg.org/Freeyourgadget/Gadgetbridge) mobile-application. Gadgetbridge is amazing for at-a-glace statistics. This is meant to augment Gadgetbridge, it is a way to visualize and aggregate long term data in a meaningful way. This app's philosophy is inline's with Gadgetbridge's: to respect the user's privacy, to rely on local data processing, and to put you completely in control of your health data.

This is still pre-alpha.

## Supported Devices and Firmware
| Device      | Firmware Vsn |
| ----------- | ------------ |
| MiBand6     | V1.0.6.16    |

## Privacy TODOs
1. Install Google fonts locally.
2. Bundle material design icons locally.
3. Move all CDN libs to npm assets.

## Deployment TODOs
1. Explore using [Bakeware](https://github.com/bake-bake-bake/bakeware) to create a single file executable.
2. TOML configuration file.
3. Companion app to synchronize sqlite database between GB and GBV.

## Development
To start the Gadgetbridge development server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
