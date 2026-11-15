-- Quizzes in a running lesson: the teacher asks, the system picks one present or late student in the room (those asked
-- least first) and only they answer, on the phone or the paper card. A right answer gives the lesson's XP to every
-- present or late student and a little more to the answerer; a wrong one or none gives nobody anything.
Config.LessonQuiz = {
    Commands = { quiz = 'quiz' }, -- reopens the paper card while a question is open

    DefaultSeconds = 30,
    TimeChoices = { 15, 30, 45, 60, 90 },
    ExtendSeconds = 15,
    MaxExtends = 2,              -- times a teacher may add time to an open question
    MaxQuestionsPerLesson = 8,   -- questions one lesson may ask; asking the same one again does not count
    MaxAsksPerQuestion = 3,      -- the first student and two more after a wrong answer or none
    AskGapSeconds = 5,           -- least time between two questions in a lesson
    PickInRoom = true,           -- only students inside the classroom (near the teacher outdoors) are picked
    MinAnswerMs = 700,           -- answers faster than this after a question opens are refused
    LatencyGraceMs = 800,        -- late answers within this are still taken
    RevealEachRound = true,      -- the asked student sees the right answer when the question closes
    Reach = 0,                   -- metres from the teacher to answer; 0 = off

    -- A right answer: Class XP to every present or late student, Answerer on top for the one asked.
    -- The daily limit is config/academics.lua Daily.SourceTotals.quiz.
    Reward = { Class = 10, Answerer = 5 },

    -- Where students answer: the Student Phone for those who carry one, College's paper card for the rest.
    AnswerOn = { phone = true, paper = true },
    PaperKeys = { 157, 158, 160, 164 }, -- keys 1-4 pick a choice on the paper card; 1 starts writing or playing

    Bank = { MaxPerLesson = 300, PromptMax = 300, ChoiceMax = 120, MinChoices = 2, MaxChoices = 4, OpenMax = 200, TopicMax = 40 },
    Retention = { QuizDays = 180 }, -- older quizzes are deleted at night (0 = keep)

    -- Lesson key = activity rounds a teacher may run there with the minigames (content in config/minigames.lua Banks
    -- under the same key), played by everyone; each 0-100 score is activity XP (Xp.MinigamePerScore). Other lessons
    -- ask questions only.
    Lessons = {
        -- first_aid = { activities = { 'cpr', 'timing', 'sequence', 'matching' }, level = 'normal', topics = { 'cpr', 'wounds' } },
        -- gastronomy = { activities = { 'sequence', 'matching' } },
        -- justice = { activities = { 'matching' } },
        -- At stations (config/practicals.lua, a station placed near the teacher): 'lab_mix' (bank .lab), 'cpr' (bank .cpr).
        -- chemistry = { activities = { 'lab_mix', 'matching' } },
    },
}
