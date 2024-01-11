# esteem

A neat Bash script to build/install/update the Enlightenment ecosystem on Ubuntu 23.04 or 23.10.

Please take a look at the comments in the script before running it.

> [!NOTE]
> It can be useful to keep a record of the pre-existing system status, before proceeding with the installation.
>
> Check out our [backup script](https://gist.github.com/batden/993b5ee997b3df2c3b075907a1dff116).

## Get started

Before using esteem, you will need to install the git and sound-icons packages on your system.

Open a terminal window and type in the following:

```bash
sudo apt install git sound-icons
```

Next, clone this repository:

```bash
git clone https://github.com/batden/esteem.git .esteem
```

This creates a new hidden folder named .esteem in your home directory.

Copy the esteem.sh file from the new .esteem folder to your download folder.

Navigate to the download folder and make the script executable:

```bash
chmod +x esteem.sh
```

Then execute the script with:

```bash
./esteem.sh
```

To run it again later, open a terminal and simply type:

```bash
esteem.sh
```

> [!TIP]
> Use auto-completion: Type *est* and press the Tab key.

## Update local repo

To update the local repository, change to ~/.esteem/ and run:

```bash
git pull
```

## Uninstalling

You can uninstall Enlightenment and related applications from your computer at any time.

See [meetse.sh](https://github.com/batden/meetse).
