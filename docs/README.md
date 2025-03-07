# Architecture documentation

## Introduction
Please see the [content/architecture/](content/architecture) folder for the architecture documentation. The content is organized according to the [arc42](https://arc42.org/) template.

## Technical details
* Documentation is written in Markdown.
* Diagrams are created in [diagrams.net/draw.io](https://www.drawio.com/) format and stored as SVG. Editors are available online or as a plugin for your favourite IDE (for e.g. [Intellij Diagram.net Integration](https://plugins.jetbrains.com/plugin/15635-diagrams-net-integration)).
* The documentation is using the [HUGO](https://gohugo.io/) framework for site generation. 
* The theme is based on [hextra](https://github.com/imfing/hextra). See the [documentation](https://imfing.github.io/hextra/docs/) to learn more about advanced features.

## Writing documentation
Simply contribute to the existing Markdown and SVG files.

Each Markdown file has a header section called [front matter](https://gohugo.io/content-management/front-matter/) containing metadata for HUGO.

If you need more Markdown features, see the [configuration](https://gohugo.io/getting-started/configuration-markup/) section in the HUGO documentation.

## Building the site locally
1. [Install HUGO](https://gohugo.io/installation/)
2. `cd docs/hugo-config`
3. Run `hugo server --buildDrafts`
4. Open [localhost:1313](http://localhost:1313/) in your browser

## Update hextra theme
1. `cd docs/hugo-config`
2. `hugo mod get -u`
