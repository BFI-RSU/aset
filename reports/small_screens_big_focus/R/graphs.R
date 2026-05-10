library(ggplot2)
library(dplyr)
library(scales)
library(ggtext)
library(gridExtra)
library(purrr)
library(ggplot2)
library(stringr)
library(forcats)
library(ggrepel)
library(plotly)
library(knitr)
library(htmlwidgets)
library(patchwork)


# set font point sizes here
html_text_size = 12
pdf_text_size = 14


plot_horizontal_bar <- function(
  data,
  category_var,           # categorical variable (string)
  value_var,              # numeric variable (string)
  comparison_var = NULL,
  value_var_tooltip_label = NULL,     # optional variable for tooltip text of value_var
  comparison_var_tooltip_label = NULL, # optional variable for tooltip text of comparison_var
  keyword = NULL,       # text to highlight categories containing this word
  highlight_color = "#e50076",  # colour for highlight bars
  base_color = "grey70",        # colour for all other bars
  title = NULL,
  subtitle = NULL,
  label_format = scales::comma,
  wrap_width = 20
) {

  is_html <- knitr::is_html_output()

  # Prepare data
  plot_data <- data %>%
    mutate(
      category_label = str_wrap(.data[[category_var]], width = wrap_width),
      highlight_flag = if (!is.null(keyword) && keyword != ""){
        str_detect(tolower(.data[[category_var]]), tolower(keyword))
      } else {FALSE},
      
      value_var_tooltip = paste0(value_var_tooltip_label, ": ",
                            label_format(.data[[value_var]]), "%"),

      comparison_var_tooltip = if (!is.null(comparison_var)) {
        paste0(comparison_var_tooltip_label, ": ",
               label_format(.data[[comparison_var]]), "%")
      } else {""},
    ) %>%
    arrange(desc(.data[[value_var]])) %>%
    mutate(category_label = forcats::fct_reorder(category_label, .data[[value_var]]))

  # Base plot
  p <- ggplot(plot_data, aes(
    x = category_label,
    y = .data[[value_var]],
    fill = highlight_flag
  )) +
    geom_col(aes(text = value_var_tooltip), width = 0.7) +
    coord_flip() +
    scale_fill_manual(
      values = c(`TRUE` = highlight_color, `FALSE` = base_color)
    ) +
    labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = NULL
    ) +
    theme_minimal(base_size = if (is_html) html_text_size else pdf_text_size) +
    theme(
      legend.position = "none",
      plot.title.position = "plot",
      plot.subtitle = element_textbox_simple(margin = margin(b = 15))
    )

    {if (!is_html) {
      p <- p + geom_text(
        aes(label = label_format(.data[[value_var]])),
        hjust = 1.5,
        size = pdf_text_size * 0.8 / ggplot2::.pt,
        color = "white"
      )
    }}

  if (!is.null(comparison_var)) {
    p <- p +
      geom_point(aes(y = .data[[comparison_var]], text = comparison_var_tooltip),
        color = "#e50076",
        fill = "#e50076",
        size = 3) +
      geom_segment(aes(
        y = .data[[comparison_var]],
        yend = .data[[comparison_var]],
        x = as.numeric(category_label) - 0.3,
        xend = as.numeric(category_label) + 0.3
      ),
      color = "#e50076",
      size = 1)

  if (!is_html) {    
    p <- p + 
      geom_text_repel(
        aes(
          y = .data[[comparison_var]],
          label = label_format(.data[[comparison_var]])),
        nudge_y = ifelse(plot_data[[comparison_var]] >= plot_data[[value_var]], 1, -1),
        direction = "x",
        hjust = 0,
        size = pdf_text_size * 0.8 / ggplot2::.pt,
        color = "#e50076"
      )
    }
  }
     
  p <- p + expand_limits(y = 1.05 * max(plot_data[[value_var]], na.rm = TRUE))


  if (is_html) {
    # Return interactive Plotly for HTML

    fig_height_in <- knitr::opts_current$get("fig.height")
    height_px <- fig_height_in * 96
    
    plotly_title <- if (!is.null(subtitle)) {
    paste0(title, "<br><span style='font-size: 0.8em; opacity: 0.8;'>", subtitle, "</span>")
  } else {
    title
  }

    widget <- ggplotly(p, tooltip = "text") %>%
      layout(
        font = list(family = "Source Sans Pro"),
        title = list(text = plotly_title),
        height = height_px,
        autosize = TRUE,
        margin = list(t = 120, b = 40, l = 10, r = 10)
      ) %>%
      config(
        displayModeBar = FALSE,
        responsive = TRUE
      )

    # Automatically adjust height based on fig.height option
    htmlwidgets::onRender(widget, sprintf("
      function(el) {
        el.style.height = '%dpx';
      }
    ", height_px))
    
    } else {
    # Return static ggplot for PDF/Word
    return(p)}
  }


plot_horizontal_bar_grouped <- function(
  data,
  screen_var,           
  content_var,          
  x_var,                
  groups = NULL,
  main_group = NULL,
  comparison_group_1 = NULL,
  comparison_group_2 = NULL,
  title = NULL,
  subtitle = NULL,
  label_format = scales::comma
) {

  plot_data <- data

  # Filter main group if specified
  if (!is.null(main_group)) {
    plot_data <- plot_data %>% filter(!!sym(groups) == main_group)
  }

  # Ensure comparison columns exist
  plot_data <- plot_data %>%
    mutate(
      comparison_value_1 = NA_real_,
      comparison_value_2 = NA_real_
    )

  # Join comparison group 1 if provided
  if (!is.null(comparison_group_1)) {
    compare_data_1 <- data %>%
      filter(!!sym(groups) == comparison_group_1) %>%
      select(
        !!sym(screen_var),
        !!sym(content_var),
        comparison_value_1 = !!sym(x_var)
      )

    plot_data <- plot_data %>%
      left_join(compare_data_1, by = c(screen_var, content_var)) %>%
      mutate(comparison_value_1 = coalesce(comparison_value_1.y, comparison_value_1.x)) %>%
      select(-comparison_value_1.x, -comparison_value_1.y)
  }

  # Join comparison group 2 if provided
  if (!is.null(comparison_group_2)) {
    compare_data_2 <- data %>%
      filter(!!sym(groups) == comparison_group_2) %>%
      select(
        !!sym(screen_var),
        !!sym(content_var),
        comparison_value_2 = !!sym(x_var)
      )

    plot_data <- plot_data %>%
      left_join(compare_data_2, by = c(screen_var, content_var)) %>%
      mutate(comparison_value_2 = coalesce(comparison_value_2.y, comparison_value_2.x)) %>%
      select(-comparison_value_2.x, -comparison_value_2.y)
  }

  # Y-axis factor for content_type
  plot_data <- plot_data %>%
    arrange(.data[[screen_var]], .data[[content_var]]) %>%
    mutate(y_axis = factor(.data[[content_var]], levels = unique(.data[[content_var]])))

  # Base plot
  ggplot(plot_data, aes(
      y = y_axis,
      x = .data[[x_var]],
      fill = .data[[content_var]]
    )) +
    geom_bar(stat = "identity") +
    scale_fill_grey(start = 0.4, end = 0.7) +

    # Comparison group 1
    geom_point(
      data = plot_data %>% filter(!is.na(comparison_value_1)),
      aes(x = comparison_value_1, y = y_axis),
      color = "#e50076",
      size = 3
    ) +
    geom_segment(
      data = plot_data %>% filter(!is.na(comparison_value_1)),
      aes(
        x = comparison_value_1,
        xend = comparison_value_1,
        y = as.numeric(y_axis) - 0.2,
        yend = as.numeric(y_axis) + 0.2
      ),
      color = "#e50076",
      size = 1
    ) +

    # Comparison group 2
    geom_point(
      data = plot_data %>% filter(!is.na(comparison_value_2)),
      aes(x = comparison_value_2, y = y_axis),
      color = "#1197FF",
      size = 3
    ) +
    geom_segment(
      data = plot_data %>% filter(!is.na(comparison_value_2)),
      aes(
        x = comparison_value_2,
        xend = comparison_value_2,
        y = as.numeric(y_axis) - 0.2,
        yend = as.numeric(y_axis) + 0.2
      ),
      color = "#1197FF",
      size = 1
    ) +

    # Labels inside bars
    geom_text(
      aes(label = label_format(.data[[x_var]])),
      hjust = 1.5,
      size = pdf_text_size * 0.8 / ggplot2::.pt,
      color = "white"
    ) +

    facet_wrap(
      as.formula(paste("~", screen_var)),
      ncol = 1,
      scales = "free_y",
      strip.position = "right"
    ) +

    scale_x_continuous(
      limits = c(0, 100),
      breaks = seq(0, 100, by = 20),
      labels = label_format,
      expand = expansion(mult = c(0, 0.1))
    ) +

    labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = NULL
    ) +

    theme_minimal(base_size = if (is_html) html_text_size else pdf_text_size) +
    theme(
      legend.position = "none",
      plot.subtitle = element_textbox_simple(margin = margin(b = 15))
    )
}



plot_vertical_bar_grouped <- function(
  data,
  screen_var,           
  content_var,          
  y_var,                
  groups = NULL,
  main_group = NULL,
  comparison_group_1 = NULL,
  comparison_group_2 = NULL,
  main_group_tooltip_label = NULL,
  comparison_group_1_tooltip_label = NULL,
  comparison_group_2_tooltip_label = NULL,
  title = NULL,
  subtitle = NULL,
  label_format = scales::comma,
  y_limits = c(0, 100),
  wrap_width = 20,
  facet_ncol = 4,
  number_of_rows = 1 # for html output only, controls numbers of rows when facet_wrap is not used to prevent excessive white space
) {

  is_html <- knitr::is_html_output()

  plot_data <- data

  # Filter main group if specified
  if (!is.null(main_group)) {
    plot_data <- plot_data %>% filter(!!sym(groups) == main_group)
  }

  # Ensure comparison columns exist
  plot_data <- plot_data %>%
    mutate(
      comparison_value_1 = NA_real_,
      comparison_value_2 = NA_real_
    )

  # Join comparison group 1 if provided
  if (!is.null(comparison_group_1)) {
    compare_data_1 <- data %>%
      filter(!!sym(groups) == comparison_group_1) %>%
      select(
        !!sym(screen_var),
        !!sym(content_var),
        comparison_value_1 = !!sym(y_var)
      )

    plot_data <- plot_data %>%
      left_join(compare_data_1, by = c(screen_var, content_var)) %>%
      mutate(comparison_value_1 = coalesce(comparison_value_1.y, comparison_value_1.x)) %>%
      select(-comparison_value_1.x, -comparison_value_1.y)
  }

  # Join comparison group 2 if provided
  if (!is.null(comparison_group_2)) {
    compare_data_2 <- data %>%
      filter(!!sym(groups) == comparison_group_2) %>%
      select(
        !!sym(screen_var),
        !!sym(content_var),
        comparison_value_2 = !!sym(y_var)
      )

    plot_data <- plot_data %>%
      left_join(compare_data_2, by = c(screen_var, content_var)) %>%
      mutate(comparison_value_2 = coalesce(comparison_value_2.y, comparison_value_2.x)) %>%
      select(-comparison_value_2.x, -comparison_value_2.y)
  }

  # X-axis factor for content_type
  plot_data <- plot_data %>%
    mutate(
      content_wrapped = str_wrap(.data[[content_var]], width = wrap_width),
      screen_wrapped = str_wrap(.data[[screen_var]], width = wrap_width),
      main_group_tooltip = paste0(main_group_tooltip_label, ": ", label_format(.data[[y_var]]), "%"),
      comparison_group_1_tooltip = if (!is.null(comparison_group_1)) {
        paste0(comparison_group_1_tooltip_label, ": ", label_format(comparison_value_1), "%")
      } else {""},
      comparison_group_2_tooltip = if (!is.null(comparison_group_2)) {
        paste0(comparison_group_2_tooltip_label, ": ", label_format(comparison_value_2), "%")
      } else {""}
    ) %>%
    arrange(.data[[screen_var]], .data[[content_var]]) %>%
    mutate(x_axis = factor(content_wrapped, levels = unique(content_wrapped)))


  # Base plot
  p <- ggplot(plot_data, aes(
      x = x_axis,
      y = .data[[y_var]],
      fill = .data[[content_var]],
      text = main_group_tooltip
    )) +
    geom_bar(stat = "identity") +
    scale_fill_grey(start = 0.4, end = 0.7) +
        facet_wrap(
      ~screen_wrapped,
      ncol = facet_ncol,
      scales = "free_x",
      strip.position = "top"
    ) +

    scale_y_continuous(
      limits = y_limits,
      breaks = seq(0, 100, by = 20),
      labels = label_format,
      expand = expansion(mult = c(0, 0.05))
    ) +

    labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = NULL
    ) +

    theme_minimal(base_size = if (is_html) html_text_size else pdf_text_size) +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.subtitle = element_textbox_simple(margin = margin(b = 15))
    )

  # Comparison group 1
  if (!is.null(comparison_group_1)) {
    df_c1 <- plot_data %>% dplyr::filter(!is.na(comparison_value_1))

    if (nrow(df_c1) > 0) {
      p <- p + geom_point(
        data = df_c1,
        aes(y = comparison_value_1, text = comparison_group_1_tooltip),
        color = "#e50076",
        fill = "#e50076",
        size = 3
      ) +
      geom_segment(
        data = df_c1,
        aes(
          y = comparison_value_1,
          text = comparison_group_1_tooltip,
          yend = comparison_value_1,
          x = as.numeric(x_axis) - 0.2,
          xend = as.numeric(x_axis) + 0.2
        ),
        color = "#e50076",
        size = 1
      )
    }
  }

  # Comparison group 2
  if (!is.null(comparison_group_2)) {
    df_c2 <- plot_data %>% dplyr::filter(!is.na(comparison_value_2))

    if (nrow(df_c2) > 0) {
      p <- p + geom_point(
        data = df_c2,
        aes(y = comparison_value_2, text = comparison_group_2_tooltip),
        color = "#1197FF",
        fill = "#1197FF",
        size = 3
      ) +
      geom_segment(
        data = df_c2,
        aes(
          y = comparison_value_2,
          text = comparison_group_2_tooltip,
          yend = comparison_value_2,
          x = as.numeric(x_axis) - 0.2,
          xend = as.numeric(x_axis) + 0.2
        ),
        color = "#1197FF",
        size = 1
      )
    }
  }

  if (!is_html) {
    p <- p + geom_text(
      aes(label = label_format(round(.data[[y_var]], 0))),
      vjust = 1.5,
      size = pdf_text_size * 0.8 / ggplot2::.pt,
      color = "white"
    )
  }

  if (is_html) {
    # Return interactive Plotly for HTML

    fig_height_in <- knitr::opts_current$get("fig.height")
    height_px <- fig_height_in * 96
    
    plotly_title <- if (!is.null(subtitle)) {
    paste0(title, "<br><span style='font-size: 0.8em; opacity: 0.8;'>", subtitle, "</span>")
  } else {
    title
  }

  margin_vals <- if (is.null(title)) {
    list(t = 40,  b = 40, l = 10, r = 10)
  } else {
    list(t = 120, b = 40, l = 10, r = 10)
  }

    widget <- ggplotly(p, tooltip = "text") %>%
      layout(
        font = list(family = "Source Sans Pro"),
        title = list(text = plotly_title),
        height = height_px/number_of_rows,
        autosize = TRUE,
        margin = margin_vals
      ) %>%
      config(
        displayModeBar = FALSE,
        responsive = TRUE
      )

    htmlwidgets::onRender(widget, sprintf("
      function(el) {
        el.style.height = '%dpx';
      }
    ", height_px/number_of_rows))
    
    } else {
    # Return static ggplot for PDF/Word
    return(p)}
  }


plot_film_by_need_states <- function(
  data,
  need_var,       
  age_var,         
  selected_age = NULL,           
  difference = FALSE,    # show difference 16_24 - all_adults
  title = NULL,
  subtitle = NULL,
  geom_type = c("line", "point"),
  wrap_width = 20,
  colors = NULL,
  y_limits = NULL,
  label_format = scales::comma
) {

  is_html <- knitr::is_html_output()

  geom_type <- match.arg(geom_type)

  plot_data <- data

  # Filter selected age if specified
  if (!is.null(selected_age)) {
    plot_data <- plot_data %>% filter(.data[[age_var]] == selected_age)
    difference <- FALSE  # can't do difference with single age
  }

  watch_cols <- setdiff(names(plot_data), c(need_var, age_var))

  # Pivot longer
  plot_data <- plot_data %>%
    pivot_longer(
      cols = all_of(watch_cols),
      names_to = "watch_method",
      values_to = "percentage"
    ) %>%
    mutate(
      watch_method_wrapped = str_wrap(watch_method, width = wrap_width) 
    )

  # Reorder need_var by average percentage across all watch methods
  need_order <- plot_data %>%
    group_by(.data[[need_var]]) %>%
    mutate(avg_value = mean(percentage, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(need_var_ordered = factor(.data[[need_var]], levels = unique(.data[[need_var]][order(-avg_value)]))) %>%
    select(.data[[need_var]], need_var_ordered) %>%
    distinct()

  if (difference) {
    # Spread age_var to wide so we can compute 16_24 - all_adults
    plot_data <- plot_data %>%
      pivot_wider(names_from = age_var, values_from = percentage) %>%
      mutate(
        percentage = `16_24` - all_adults,
        tooltip_text = paste0(watch_method, " (difference): ", label_format(percentage), "pp")) %>%
      select(-all_of(c("16_24", "all_adults"))) %>%
      left_join(need_order, by = need_var)
  } else {
    # Join ordering
    plot_data <- plot_data %>% 
      mutate(tooltip_text = paste0(watch_method, ": ", label_format(percentage), "%")) %>%
      left_join(need_order, by = need_var)
  }

  if (is.null(colors)) {
    colors <- scales::hue_pal()(length(unique(plot_data$watch_method_wrapped)))
  }

  my_colours <- c("#e50076", "#1197FF", "dimgrey", "darkgrey")

  # Build plot
  p <- ggplot(plot_data, aes(x = need_var_ordered, y = percentage,
                        group = watch_method_wrapped, color = watch_method_wrapped, text = tooltip_text)) +
    {if (difference) geom_hline(yintercept = 0, color = "black", linetype = "solid") else NULL} +
    {if (geom_type == "line") geom_line(size = 1.2) else geom_point(size = 3)} +
    {if (geom_type == "line") geom_point(size = 3) else NULL} +
    {if (is.null(selected_age) && !difference && length(unique(plot_data[[age_var]])) > 1) facet_wrap(
      as.formula(paste("~", age_var)),
      ncol = 1,
      labeller = labeller(
        !!age_var := c("all_adults" = "All adults",
                       "16_24" = "Aged 16-24")
      )) else NULL} +
    scale_y_continuous(labels = label_format, limits = y_limits, breaks = seq(-100, 100, by = 20)) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = wrap_width)) +
    scale_color_manual(values = my_colours) +
    labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = NULL,
      color = "Watch method"
    ) +
    theme_minimal(base_size = if (is_html) html_text_size else pdf_text_size) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )

  if (is_html) {
    # Return interactive Plotly for HTML

    fig_height_in <- knitr::opts_current$get("fig.height")
    height_px <- fig_height_in * 96
    
    plotly_title <- if (!is.null(subtitle)) {
    paste0(title, "<br><span style='font-size: 0.8em; opacity: 0.8;'>", subtitle, "</span>")
  } else {
    title
  }

    widget <- ggplotly(p, tooltip = "text") %>%
      layout(
        font = list(family = "Source Sans Pro"),
        title = list(text = plotly_title),
        height = height_px,
        autosize = TRUE,
        margin = list(t = 120, b = 40, l = 10, r = 10),
        legend = list(
          orientation = "h",
          x = 0.5,
          xanchor = "center",
          y = -0.7,
          yanchor = "bottom"
        )
      ) %>%
      config(
        displayModeBar = FALSE,
        responsive = TRUE
      )

    # Position panel titles within plot area
    y_axes <- grep("^yaxis", names(widget$x$layout), value = TRUE)
    
    # check number of annotations
    n_annotations <- length(widget$x$layout$annotations)

    for (i in seq_along(y_axes)) {
      # Only adjust annotation if it exists for this y-axis
      if (i <= n_annotations) {
        dom <- widget$x$layout[[y_axes[i]]]$domain
        widget$x$layout$annotations[[i]]$y <- dom[2] - 0.2
      }
    }

    htmlwidgets::onRender(widget, sprintf("
      function(el) {
        el.style.height = '%dpx';
      }
    ", height_px))
    
    } else {
    # Return static ggplot for PDF/Word
    return(p)}
  }


plot_diverging_bar <- function(
  data,
  category_var,           # categorical variable (string)
  agree_var,              # numeric variable for Agree (string)
  disagree_var,           # numeric variable for Disagree (string)
  agree_color = "#e50076",    # Color for right side
  disagree_color = "#1197FF", # Color for left side
  title = NULL,
  subtitle = NULL,
  label_format = scales::number_format(accuracy = 1),
  wrap_width = 20
) {
  
  is_html <- knitr::is_html_output()

  # Prepare data (Pivot and Negative Calculation)
  plot_data <- data %>%
    select(
      category = .data[[category_var]], 
      Agree = .data[[agree_var]], 
      Disagree = .data[[disagree_var]]
    ) %>%
    # Convert to long format for ggplot
    pivot_longer(cols = c(Agree, Disagree), names_to = "Sentiment", values_to = "Value") %>%
    mutate(
      category_label = str_wrap(category, width = wrap_width),
      # Make Disagree negative to push it left of 0
      Display_Value = ifelse(Sentiment == "Disagree", -Value, Value),
      # Calculate text position (just inside the bar ends)
      Text_Hjust = ifelse(Sentiment == "Disagree", -0.5, 1.5),
      # Tooltip text
      tooltip_text = paste0(
        label_format(Value), "% ", tolower(Sentiment)
      )
    )
  
  # Sorting Logic: Order categories by the magnitude of 'Agree'
  # We create a sorting order based on the Agree values
  order_levels <- plot_data %>%
    filter(Sentiment == "Agree") %>%
    arrange(Value) %>%
    pull(category_label)
  
  plot_data$category_label <- factor(plot_data$category_label, levels = order_levels)

  # Calculate annotation positions on x-axis
  n_cats <- length(unique(plot_data$category_label))

  # Base Plot
  p <- ggplot(plot_data, aes(x = category_label, y = Display_Value, fill = Sentiment, text = tooltip_text)) +
    geom_col(width = 0.7) +
    coord_flip(clip = "off") +

    # Scales and Colors
    scale_fill_manual(values = c("Agree" = agree_color, "Disagree" = disagree_color)) +
    scale_y_continuous(labels = function(x) label_format(abs(x))) + # Fix axis labels
    
    # Theme and Layout
    labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = NULL,
      fill = NULL
    ) +
    theme_minimal(base_size = if (is_html) html_text_size else pdf_text_size) +
    theme(
      legend.position = "none",
      plot.subtitle = element_textbox_simple(margin = margin(b = 15)),
      panel.grid.major.y = element_blank() # Remove horizontal grid lines for cleanliness
    )

  # bar value labels
  if (!is_html) {  
    p <- p + geom_text(
      aes(
        label = label_format(abs(Display_Value)), # abs() hides the negative sign
        hjust = Text_Hjust
      ),
      size = pdf_text_size * 0.8 / ggplot2::.pt,
      color = "white",
      fontface = "bold"
    ) +
    # annotations
    annotate("text", x = n_cats + 1, y = -1,
             label = "Disagree", color = disagree_color, fontface = "bold", size = 4.5, hjust = 1) +
    annotate("text", x = n_cats + 1, y = 1,
             label = "Agree", color = agree_color, fontface = "bold", size = 4.5, hjust = 0)
  }
    
if (is_html) {
    # Return interactive Plotly for HTML

    fig_height_in <- knitr::opts_current$get("fig.height")
    height_px <- fig_height_in * 96
    
    plotly_title <- if (!is.null(subtitle)) {
    paste0(title, "<br><span style='font-size: 0.8em; opacity: 0.8;'>", subtitle, "</span>")
  } else {
    title
  }

    widget <- ggplotly(p, tooltip = "text") %>%
      layout(
        font = list(family = "Source Sans Pro"),
        title = list(text = plotly_title),
        height = height_px,
        autosize = TRUE,
        margin = list(t = 120, b = 40, l = 10, r = 10)
      ) %>%
      config(
        displayModeBar = FALSE,
        responsive = TRUE
      )

    htmlwidgets::onRender(widget, sprintf("
      function(el) {
        el.style.height = '%dpx';
      }
    ", height_px))
    
    } else {
    # Return static ggplot for PDF/Word
    return(p)}
  }