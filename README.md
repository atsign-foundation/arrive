<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

# atArrive README

atArrive makes peer-to-peer encrypted location sharing easy. 

## Who is this for?

We have open sourced @‎rrive so that you can see how apps on The @ Platform
work. We also welcome issues and pull requests so that we can make @‎rrive
better.

To access map and location search:
 - Create `.env` file in the root of the project.
 - And add these lines in the `.env` file.
 ```
MAP_KEY = '<insert_your_map_key_here>' 
API_KEY = '<insert_your_api_key_here>'
 ```

### Steps to get mapKey

  - Go to https://cloud.maptiler.com/maps/streets/
  - Click on `sign in` or `create a free account`
  - Come back to https://cloud.maptiler.com/maps/streets/ if not redirected automatically
  - Get your key from your `Embeddable viewer` input text box 
    - Eg : https://api.maptiler.com/maps/streets/?key=<YOUR_MAP_KEY>#-0.1/-2.80318/-38.08702
  - Copy <YOUR_MAP_KEY> and use it.

### Steps to get apiKey

  - Go to https://developer.here.com/tutorials/getting-here-credentials/ and follow the steps

### Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) has detailed guidance on how to make a
pull request.

## Maintainers

Created by @sarika01, @sachins-geekyants and @nitesh2599
