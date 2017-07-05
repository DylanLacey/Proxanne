# Proxanne

Proxanne; When your Browsermob Proxy just isn't Sauce Connect-y enough and your HAR files are no-where to be found.

Proxanne manages startup and configuration of BMP and SC, forcing them to play nice like a sturdy old Kindergarten teacher.  

Ask her politely and she might even show you their fingerpaintings (by which I mean HAR files.)

## Installation

    $ gem install proxanne

Then, run `proxanne` to create `~/.proxanne` and `~/.proxanne/proxanne.conf`.  Open `proxanne.conf` in your favorite editor and fill in the blanks.

## Usage

Run `proxanne` and wait for it to tell you it's ready and capturing.  When you want to save a HAR file, enter the filename and hit enter, or just hit enter to accept the default filename.

Type `quit` to leave.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dylanlacey/proxanne. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

