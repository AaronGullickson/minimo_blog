---
title: My First GitHub Repository
author: Aaron Gullickson
date: '2016-08-16'
slug: firstgithubrep
categories: []
tags: [github, git, open science, ancestry]
subtitle: ''
summary: 'in which I become and open scientist'
lastmod: '2016-08-16T11:17:18-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

The [recent crisis of replication](https://en.wikipedia.org/wiki/Replication_crisis) in psychology has increased [the call](http://opensciencefederation.com/) to make our research analyses more open and reproducible. It is a movement that I fully support in principle, although there is little institutional support for it and limited incentive given the current norms of social science production and publication.

Over the last couple of years, I have been trying to incorporate more of the philosophy behind open-source programming into my research practices. Most notably, I have been keeping track of my research projects using the [git](https://git-scm.com/) version control system. Version control has numerous benefits such as providing an effective back-up system, the ability to sync easily across different computers, a complete log of changes made, the ability to revert to prior versions, and the ability to collaborate without having to akwardly pass back and forth files and data with dates and version numbers ridiculously hardcoded into the file name (e.g. ourpaper06112015v12_agedits.docx).

Because I was using git already, it occurred to me that it should be straightforward to just make my repository available on [GitHub](https://github.com/) for other scholars to clone. So, I decided to set up a GitHub repository for the the analysis from my most recent article "[Essential Measures: Ancestry, Race, and Social Difference](http://abs.sagepub.com/content/60/4/498)" published in the American Behavioral Scientist.

After much trial and tribulation, that [Github repository is now available](https://github.com/AaronGullickson/essentialmeasures). It turned out to be a much more time-consuming process than simply cloning my existing repository. That repository was my own private fiefdom and although I always try to comment my code well and organize my scripts systematically, it was still littered with still-born and abandoned scripts, spots of poor commenting where even I couldn't quite remember what I did, and the sloppy dumping of all output files and datasets into the same base directory. Ultimately, I had to start with a fresh repository, which I then selectively copied scripts into after cleaning up their commenting. I then had to make sure the whole thing actually still worked and replicated my analysis (spoiler: it did). In other words, it took a significant amount of "curating" to whip my code into something that would be intelligible by others.

I probably could have started with an easier project, in retrospect. This project involved Stata, R, and python scripts. Stata was the primary workhorse, which is a little unusual for me (normally its R). That caused all sorts of problems setting up a bash script to run the whole analysis because it appears that a command line stata executable is not linked to your path when you install Stata. The python script is also tricky because it requires the use of a special library called [THOTH](http://tuvalu.santafe.edu/~simon/page7/page7.html) for calculating entropy via bootstrap. This library is difficult to install. I was able to install it on my linux box, but never could get it to work on my mac laptop. So, I ended up writing an alternate R script to calculate entropy for users who might not be able to get THOTH installed.

I learned a lot in the process of creating the repository. It really helped me think about how to organize my research practices from the beginning so that the level of curating necessary to produce this public record will be minimal. The knowledge that all of your analyses will be public in the future is a great motivator for writing clear and well-organized code. Some may [turn their nose up](http://www.nejm.org/doi/full/10.1056/NEJMe1516564) at open science as some kind of objectionable surveillance. On the contrary, I have found that it really helps us as researchers be more clear from the beginning about what it is we are doing. It makes me feel like I am in dialogue with a larger community even as I sit in my office writing code with the lights off.

Here are some more practical points I have taken from the exercise:

1. The first thing that should go into any research project is a README file that can be updated as the project progresses. This README file should explain the relationship between the various scripts, data sources, and outputs.

2. Data restrictions! This project uses [IPUMS](http://www.ipums.org) data. I am so used to the free and open nature of IPUMS data that it didn't occur to me until late in the process that I might not be able to re-distribute my data. Sure enough, the data contract with IPUMS indicates that you cannot re-distribute without explicit permission, unless replicability is required by a journal. I understand the requirement, but I also feel that it needs to be amended in order to make the scientific process more open. I sent an email inquiring about the issue, but have not yet heard back. In the meantime, I decided to make the codebook for my IPUMS extract part of the repository so that users could easily reproduce my extract. However, I do feel that the lack of raw data is likely to lead most users to give up on experimenting with the analysis unless they are very interested in the topic. Even if I do get permission however, I am not sure if I will even be able to fit the data on GitHub. I have heard conflicting reports about the maximum size of data files. Even gzipped, the raw data file from the IPUMS extract is 640mb.

3. I never really thought about licensing the code I create. However, according to GitHub's [licensing FAQ](https://help.github.com/articles/open-source-licensing/), without a license, default copyright laws apply which means "nobody else may reproduce, distribute, or create derivative works from your work." This is certainly not what I want. Luckily, Github provides a [useful website](http://choosealicense.com/) to help determine the best license. Apparently, a lot of academic work uses the [Creative Commons Attribution 4.0 license](http://choosealicense.com/licenses/cc-by-4.0/), but I felt that it seemed a bit intimidating at first glance, so I went with the short and sweet [MIT license](http://choosealicense.com/licenses/mit/).
