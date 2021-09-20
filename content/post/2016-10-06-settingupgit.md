---
title: Setting Up a Git Repository
author: Aaron Gullickson
date: '2016-10-06'
slug: settingupgit
categories: []
tags: [git]
subtitle: ''
summary: 'Basic instructions on setting up linked local and remote git repositories'
lastmod: '2016-10-06T11:17:18-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

I have really become an evangelist for using [git](https://git-scm.com/) to manage research projects. I use it now for all of my research projects, whether working in collaboration of by myself. In a future post, I will outline what I think are the many advantages of using version control for research projects. This post is more of self-centered post. I want to have a reference for remembering how to set up a fresh git repository, so I don't have to keep googling it every time to make sure I get the syntax right. I do it to infrequently to remember it, but frequently enough that its a pain that I can't remember it. I am hoping this post may also be helpful to others wanting to get started with git.

My set up is that I have a laptop running OSX and a desktop running linux. I keep a "bare" repository on the desktop that serves as my "central" repository and then I keep separate clones of that repository on both my desktop and laptop from which I work.

Typically, I will start by just setting up a directory for the research project on my laptop. In most cases, there will already be some preliminary data/code/notes in this directory. The first step is to initialize this repository. From the command line:

```bash
cd path/to/newproject/directory
git init
git add .
git commit -m "initial commit"
```

So, the git repository is now all set up on my laptop.

Next, I set up the bare repository that will serve as the "central" repo on my desktop server. I typically keep these bare repositories in a directory called "repo." Log into the account where I want the repo to be and from the command line:

```bash
cd ~/repo
mkdir newproject.git
cd newproject.git
git init --bare
```

This will initialize the empty bare git repository. The next step is to then push the actual contents from my laptop repo into that bare repository. On the laptop again, from the command line:

```bash
git remote add origin ssh://username@myserver.uoregon.edu:XXXX/home/username/repo/newproject.git
git push origin master
```

Obviously, username, myserver, and XXXX need to be replaced with real vaues for the user name, server name, and port number. Once this is done, my central repository is set up. The last step is to clone this central repo to a working repository on my desktop machine and make sure everything looks right. On the desktop, from the command line:

```bash
cd path/to/working/repo
git clone /home/username/repo/newproject.git
```

If all goes well, I should get a copy of the repository here. Note that this only works if I am on the same desktop as the bare repository with the same username. Otherwise, you would have to clone over ssh like so:

```bash
git clone ssh://username@myserver.uoregon.edu:XXXX/home/username/repo/newproject.git
```

Thats it. At this point, I have one "central" bare repository and two separate working repository on each of my computers from which I can start working, committing, pushing, and pulling changes as needed.
