library(labelled)


folder.data <- "data"


### Pheno data (meditative experience sampling)

# --- load
df <- read_tsv(file.path(folder.data, "LAMP_BPGOS_data.gz")) %>% 
  mutate(across(c(retreat, subject), as.factor)) %>% 
  mutate(across(c(EmotionsPositive, EmotionsNegative, EmotionsLow, EmotionsHigh, ThoughtsPast, ThoughtsPresent, ThoughtsFuture), as.logical)) %>% 
  mutate(MWduration = MWduration.Min + MWduration.Sec/60)

# --- analyze "MW duration = 0" events: most come from 4 subjects (132 out of 168)
df %>% filter(MWduration == 0) %>% nrow
df %>% filter(MWduration == 0) %>% filter(subject %in% c("S06","S07","S28","S39")) %>% nrow

# --- Preprocess
df <- df %>% 
  # --- replace mind-wandering duration 0 values by NA, because no MW is not plausible
  mutate(across(c(MWduration,InsightIntensity), ~replace(., .==0, NA))) %>% 
  # --- log-transform durations of mind-wandering episodes
  mutate(MWduration = log(MWduration)) %>% 
  # --- derive sensory-affective uncoupling of pain from intensity and unpleasantness
  mutate(PainUncoupling = PainIntensity-PainUnpleasantness) %>%
  # --- create a boolean variable for presence of Insight
  mutate(InsightPresence = (!InsightContent.No)) %>% 
  # --- add binary variables for presence of self-related and other-related thoughts
  mutate(ThoughtsSelf = (ThoughtsSelf.mean>1),
         ThoughtsOthers = (ThoughtsOthers.mean>1)) %>% 
  droplevels()



### Trait questionnaires

# --- load questionnaire data & do minimal wrangling
df.quest1 <- read_tsv(file.path(folder.data, "QUEST_scores_session1_2023-05-05.tsv")) %>% 
  set_value_labels(genre = c(Women = "femme", Men = "homme")) %>% 
  mutate_if(is.labelled, to_factor) %>% 
  mutate_if(is.character, as.factor) %>% 
  mutate(retreat = as.factor(retreat))

df.quest2 <- read_tsv(file.path(folder.data, "QUEST_scores_session2_2023-05-05.tsv")) %>% 
  mutate_if(is.labelled, to_factor) %>% 
  mutate_if(is.character, as.factor) %>% 
  mutate(retreat = as.factor(retreat))

# --- prepare variables' labels
quest.labels <- as.list(names(df.quest1))

quest.labels %<>% 
  # --- remove the questionnaire name from subscales 
  str_replace("[A-Z]+\\.","") %>%
  # --- relabel sum scores to "Total"
  str_replace("PCS|FFMQ|MAIA|RRS","Total") %>%
  # --- clean MAIA item names
  ifelse(. == "reward", "reward responsiveness", .) %>%
  ifelse(. == "drive", "drive", .) %>%
  ifelse(. == "fun", "fun seeking", .) %>%
  # --- clean MAIA item names
  str_replace("reg$"," regulation") %>%
  str_replace("notdistracting","not-distracting") %>%
  str_replace("notworrying","not-worrying") %>%
  str_replace("emotionalaware","emotional awareness") %>%
  str_replace("bodylistening","body listening") %>%
  # --- clean SHALOM item names
  str_replace("perso_","personal_") %>%
  str_replace("comm_","communal_") %>%
  str_replace("env_","environmental_") %>%
  str_replace("transc_","transcendental_") %>%
  str_replace("_ideal"," (ideal)") %>%
  str_replace("_feel"," (lived)") %>%
  # --- capitalize
  ifelse(. %in% c("DDS","BIS","PTQ"), ., str_to_sentence(.)) %>% 
  as.list()

names(quest.labels) <- names(df.quest1) 

# --- set variables' labels
var_label(df.quest1) <- quest.labels[names(quest.labels) %in% names(df.quest1)]
var_label(df.quest2) <- quest.labels[names(quest.labels) %in% names(df.quest2)]



### Lifetime practice

active_group = c('S01', 'S02', 'S04', 'S05', 'S07', 'S08', 'S13', 'S14', 'S15', 'S17', 'S18', 'S20', 'S21','S25', 
                 'S26', 'S31', 'S32', 'S35', 'S36', 'S41', 'S42', 'S44', 'S45', 'S49', 'S50', 'S55', 'S56')
control_group = c('S06', 'S10', 'S11', 'S12', 'S16', 'S19', 'S22', 'S23', 'S24', 'S27','S28','S29', 'S30', 'S33', 
                  'S34', 'S37', 'S38', 'S39', 'S40', 'S43', 'S46', 'S47', 'S48', 'S51', 'S52', 'S53', 'S54')

df.retreat <- df %>% group_by(subject, retreat) %>% summarize()

df.practice <- read_csv(file.path(folder.data, "allSubjects_practice.csv")) %>%
  mutate(group = as.factor(ifelse(subject %in% active_group, "active", "control")), .after=subject) %>%
  # --- exclude S38 who did not participate in the retreat 
  right_join(df.retreat) %>% filter(!is.na(retreat)) %>% 
  # --- simplify column names
  rename(usualRetreatDuration = "usualRetreatDuration (days)",
         usualRetreatPractice = "usualRetreatPractice (hours)") %>% 
  # --- for one participant who has never done a retreat, put in O days/hours
  replace_na(list("usualRetreatDuration" = 0,
                  "usualRetreatPractice" = 0)) %>% 
  set_variable_labels(totalTime = "Accumulated lifetime practice",
                      practiceTime = "Accumulated home practice",
                      retreatTime = "Accumulated retreat practice",
                      usualRetreatDuration = "Prior retreat(s) duration",
                      usualRetreatPractice = "Prior retreat(s) intensity",
                      currentDailyPractice = "Current daily practice")



### Append "metadata" to experience sampling data
df <- df %>% 
  # --- append expertise metrics
  left_join(df.practice %>% select(subject, startYear, retreatTime, practiceTime, totalTime, usualRetreatDuration, usualRetreatPractice, currentDailyPractice)) %>% 
  # --- append trait measures
  left_join(df.quest1 %>% select(subject, DDS, starts_with("PCS"), BIS, starts_with("BF."), starts_with("RRS"), starts_with("MAIA"), starts_with("FFMQ"), starts_with("PTQ"), starts_with("RRS"))) %>% 
  # --- factorize Subject
  mutate(subject = as.factor(subject))
