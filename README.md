# esteem

A neat Bash script to build/install/update the Enlightenment ecosystem on Ubuntu.

Please take a look at the comments in the script before running it.

*See also [meetse.sh](https://github.com/batden/meetse) (companion script).*

## Get started

Before using esteem, you'll need to install the git and sound-icons packages on your system.

Open a terminal window and type in the following:

```bash
sudo apt install git sound-icons
```

Next, clone this repository:

```bash
git clone https://github.com/batden/esteem.git .esteem
```

This creates a new hidden folder named **.esteem** in your home directory.

Copy the esteem.sh file from the new .esteem folder to your download folder.

Navigate to the download folder and make the script executable:

```bash
chmod +x esteem.sh
```

Run the following command:

```bash
./esteem.sh
```

On subsequent runs, open a terminal and run:

```bash
esteem.sh
```

(Use auto-completion: Just type *est* and press Tab.)

## Update local repository

Check for updates at least once a week.
In order to do this, change to ~/.esteem/ and run:

```bash
git pull
```

That's it.

Mind the cows! :cow2: :cow2: :cow2:
