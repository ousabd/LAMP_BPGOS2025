## Fit GBMT for multiple numbers of groups
gbmt.fit <- function(data, unit, time, x.names, ng.max = 1, scaling = 2, d = 2, pruning = T, quiet = F) {
  m.gbtm <- list()
  df.gbtm.ic <- tibble()
  
  for (ng in 1:ng.max) {
    m.gbtm[[ng]] <- gbmt(data = data,
                         unit = unit, time = time, x.names = x.names,
                         scaling = scaling, ng = ng, d = d, pruning = pruning, quiet = quiet)
    
    df.gbtm.ic <- bind_rows(df.gbtm.ic,
                            m.gbtm[[ng]]$ic %>% as.list() %>% as_tibble() %>% mutate(ngroups = ng))
  }
  
  return(list(models = m.gbtm, ic = df.gbtm.ic))
}



## Plot information criteria as a function of number of classes
gbmt.plot <- function(df.gbtm.ic, plot.min = F) {
  df.plot <- df.gbtm.ic %>%
    gather(metric, value, -ngroups, -degree) %>% 
    rename(`polynomial degree` = degree)
  df.plot %>% 
    ggplot(aes(x = ngroups, y = value, color = metric)) +
    facet_wrap(~ `polynomial degree`, labeller = label_both, nrow = 1) +
    geom_line() +
    scale_x_continuous(breaks = unique(df.gbtm.ic$ngroups)) +
    scale_color_brewer(palette = "Set1") +
    labs(x = "Number of classes", y = "Goodness-of-fit\n(the smaller the better)") -> gg
  
  if (plot.min) {gg <- gg + geom_point(data = df.plot %>% group_by(metric,`polynomial degree`) %>% filter(value==min(value)))}
  
  return(gg)
}
