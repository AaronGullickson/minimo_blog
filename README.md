# Professional Blog

This is the [hugo](https://gohugo.io/) content for my professional blog which is deployed at [aarongullickson.netlify.app](https://aarongullickson.netlify.app). The layout is based on the [Minimo](https://minimo.netlify.app/) theme by Munif Tanjim. The site is created and maintained using the [blogdown](https://github.com/rstudio/blogdown) package in R. 

## Adding new blog posts

New blog posts are added in `content/posts`. The blogdown addin in RStudio has a new post option which I am now using. New posts should be embedded in their own file which can also contain whatever images or additional files they need. Its also important to use the Rmarkdown rather than Rmd suffix on new posts so tha they are processed into regular markdown files rather than html. This helps to ensure code chunks show up properly. 

## Updating the CV

The content of the CV is produced by a googlesheet that is referenced in the `index.Rmd` file of the `cv` directory.  To force an update of the CV that will pull in new data from the googlesheet, simply change the date listed at the top of that `index.Rmd` file. Ideally, a new version of the PDF produced by the [my_vitae](https://github.com/AaronGullickson/my_vitae) repository should also be added at the same time. 

## Add a link in the menu

To add an internal link in the menu to a new content page, just add the following to the yaml for that file:

```yaml
linkTitle: Some Title
menu:
  main:
  sidebar:
    identifier: someid
```

To add an external link, add something like the following to the `[menu]` section of `config.toml`:

```toml
[[menu.main]]
  identifier = "someid"
  name = "A name"
  url = 'https:somelink.com'
  weight = -80
```

The weight will determine its placement.

