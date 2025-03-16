df.variables <- tribble(
  
  ~number, ~name, ~label, ~domain,
  
  "03", "SeriousMedit", "Engagement", "Conative",
  "04", "Fatigue", "Energy", "Conative",
  "05", "Sleep", "Drowsiness", "Conative",
  "15", "PhysicalEffort", "Effort for stillness", "Conative", # "Physical effort"
  "18", "MentalEffort", "Mental effort", "Conative",
  "06", "Doubt.Practice", "Confidence (practice)", "Conative",
  "07", "Doubt.Skills", "Confidence (skills)", "Conative",
  
  "12", "Tension", "Tension", "Somatic",
  "13", "Restlessness", "Restlessness", "Somatic",
  "09", "PainIntensity", "Pain intensity", "Somatic",
  "14", "Movement", "Movement", "Somatic",
  
  "08a", "EmotionsPositive", "Positive affect", "Affective",
  "08b", "EmotionsNegative", "Negative affect", "Affective",
  "10", "PainUnpleasantness", "Pain unpleasantness", "Affective",
  "derived", "PainUncoupling", "Pain uncoupling", "Affective",
  "29", "Dereification2", "Mental intrusiveness", "Affective", # "Annoyance with\nmental activity"
  "11", "Equanimity", "Reactivity", "Affective",
  
  "30a10", "ThoughtsPast", "Past-oriented thoughts", "Temporal\norientation",
  "30a11", "ThoughtsPast.depth", "Temporal dist. (past)", "Temporal\norientation",
  "30a20", "ThoughtsPresent", "Present-centered thoughts", "Temporal\norientation",
  "30a30", "ThoughtsFuture", "Future-oriented thoughts", "Temporal\norientation",
  "30a31", "ThoughtsFuture.depth", "Temporal dist. (future)", "Temporal\norientation",
  
  "30c", "ThoughtsSelf.mean", "Self-directed thoughts", "Mental content",
  "30b", "ThoughtsOthers.mean", "Other-directed thoughts", "Mental content",
  "30d1", "ThoughtsWorldly", "Worldly-related thoughts", "Mental content",
  "30d2", "ThoughtsSpiritual", "Spiritually-related thoughts", "Mental content",
  
  "17", "Stability", "State stability", "Attentional", # "Successful application\nof instructions"
  "19", "MWpresence", "Spontaneous thoughts", "Attentional",
  "21", "MWduration", "Distraction duration", "Attentional",
  "20", "MWstickiness", "Mental stickiness", "Attentional",
  "25", "Aperture", "Attentional focus", "Attentional",
  "26", "Surroundings", "Surroundings awareness", "Attentional", # "Awareness to surroundings"
  "23", "Vividness", "Clarity", "Attentional",

  "27", "MetaAwareness", "Meta-awareness", "Meta-cognitive",
  "16", "Impulses", "Premotor awareness", "Meta-cognitive", # "Awareness of\nimpulses to move"
  "22", "MWdurationConfidence", "Distraction dur. conf.", "Meta-cognitive", # "Confidence in\ndistraction duration"
  "28", "Dereification1", "Subjective realism", "Meta-cognitive",
  "31a", "InsightPresence", "Insight (frequency)", "Meta-cognitive",
  "31b", "InsightIntensity", "Insight (depth)", "Meta-cognitive"
)

df.variables <- df.variables %>% 
  group_by(domain) %>% mutate(idx = row_number()) %>% ungroup() %>%
  column_to_rownames("name")

# Make a named list with variables' labels, useful for plotting
df.variables.labels <- df.variables %>% rownames_to_column() %>% select(rowname,label) %>% deframe


# Colors of psychological domains
list.domains.ordered <- c("Somatic","Affective","Mental content",
                          "Attentional","Meta-cognitive","Conative")
cols.domains <- scales::hue_pal()(6)
names(cols.domains) <- list.domains.ordered
# --- add "temporal orientation" with same color as "mental content"
cols.domains["Temporal\norientation"] <- cols.domains["Mental content"]
# --- final order
list.domains.ordered <- c("Conative","Somatic","Affective","Temporal\norientation","Mental content",
                          "Attentional","Meta-cognitive")