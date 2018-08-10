library(showtext)

font_add_google("Roboto", "main_font")
font_add_google("Roboto", "myfont")
font_add_google("Sarala", "heading_font")

showtext_auto()
showtext_opts(dpi = 600)

myfont <- "main_font"
main_font <- "main_font"
heading_font <- "heading_font"

theme_set(theme_light(base_family = main_font) + 
            theme(legend.position = "bottom") +
            theme(plot.caption = element_text(colour = "grey50"),
                  strip.text = element_text(size = rel(1), face = "bold"),
                  plot.title = element_text(family = heading_font))
) 
update_geom_defaults("text", list(family = main_font))