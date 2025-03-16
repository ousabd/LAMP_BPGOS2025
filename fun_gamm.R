### Model fitting

gam_fit <- function(data,
                    formula,
                    list.vars = list.vars.gam,
                    family = NULL,
                    fun = gam,
                    method = "GCV.Cp",
                    print.var = TRUE,
                    print.summary = FALSE,
                    ...) {
  
  if (is.null(family)) {family <- gaussian}
  
  list.gam <- list()
  
  for (vv in list.vars) { #
    
    if (print.var) {cat(paste0("\n Fitting ", vv))}
    
    # Fit GAM
    f <- paste(vv, formula)
    
    if (is.logical(data[[vv]])) {
      data[[vv]] <- as.factor(data[[vv]])
      family <- binomial()
    } else {
      family <- gaussian()
    }
    
    gam.m <- fun(as.formula(f),
                 data = data,
                 family = family,
                 method = method,
                 ...)
    # discrete = T,
    # nthreads = 4)
    
    if (print.summary) {print(summary(gam.m))}
    list.gam[[vv]] <- gam.m
  }
  
  return(list.gam)
}



### Extract smooths

gam_emmeans <- function(models, smooths = c(1), terms = list(day = 1:10)) {
  
  # Enlist if necessary
  if (any(class(models) != "list")) {models <- list("model" = models)}
  
  # Initialize outcome dataframe
  df.out <- tibble()
  
  # Loop over models and requested smooths
  for (m in names(models)) {
    cat(paste0("\n Extracting from model ", m))
    for (s in smooths) {
      df.out %<>% bind_rows(
        ggemmeans(models[[m]], terms = terms, type = "fixed") %>%
          as.data.frame() %>% 
          mutate(variable = insight::find_response(models[[m]]),
                 smooth = insight::find_smooth(models[[m]])$smooth_terms[s],
                 smooth.idx = s,
                 model = m)
      )
    }
  }
  
  return(df.out)
}



### Extract smooths significance

p.to.sym <- function(p, ns = "n.s.") {
  cut(p, breaks = c(-Inf, 0.001, 0.01, 0.05, Inf), 
      labels = c("***", "**", "*", ns), right = FALSE)
}

gam_signif <- function(models, smooths = c(1), method = "holm", family) {
  
  # Enlist if necessary
  if (any(class(models) != "list")) {models <- list("model" = models)}
  
  # Flatten list if necessary
  if (any(class(models[[1]]) == "list")) {models <- unlist(models, recursive = F)}

  # Initialize outcome dataframe
  df.out <- tibble()
  
  # Loop over models and requested smooths
  for (m in names(models)) {
    smry <- summary(models[[m]], re.test=F)
    for (s in smooths) {
      df.out %<>% bind_rows(
        tibble(variable = insight::find_response(models[[m]]),
               smooth = insight::find_smooth(models[[m]])$smooth_terms[s],
               smooth.idx = s,
               p = smry$s.pv[s],
               model = m))
    }
  }
  
  # Apply Holm's correction for FWER & convert p-values to symbols
  df.out <- df.out %>%
    group_by(!!sym(family)) %>%
    mutate(p.corr = p.adjust(p, method = method),
           method = method) %>%
    ungroup() %>%
    mutate(sym = p.to.sym(p),
           sym.corr = p.to.sym(p.corr))
  
  return(df.out)
}



### Extract deviance explained

gam_devexpl <- function(models) {
  
  # Enlist if necessary
  if (any(class(models) != "list")) {models <- list("model" = models)}
  
  # Initialize outcome dataframe
  df.out <- tibble()
  
  for (m in names(models)) {
    f <- as.character(insight::find_formula(models[[m]])$conditional)
    df.out %<>% bind_rows(
      tibble(variable = f[2],
             formula = f[3],
             deviance = summary(models[[m]], re.test = F)$dev.expl)
    )
  }
  
  return(df.out)
}
