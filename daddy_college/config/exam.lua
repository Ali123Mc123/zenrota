-- Exams: the question bank, exam papers, timed sessions and grading.
Config.Exam = {
    Commands = { panel = 'exams', results = 'myexams' },

    PaperItem = 'exam_paper',  -- one paper per student; the database decides if it is valid, not the item
    RequireStudentJob = true,  -- only students can sit an exam
    DefaultDuration = 30,      -- minutes
    MaxDuration = 180,
    MaxQuestions = 100,
    DefaultPassPct = 50,
    PartialCredit = true,      -- multiple answer questions give part of the points
    AllowReopen = true,        -- a student may reopen an unfinished paper before the deadline
    SharedGrading = true,      -- any teacher may grade and approve, not only the exam's author
    AutosavePerSecond = 2,

    Session = { MinDuration = 5, DefaultDuration = 30, MinJoinSeconds = 60, SweepMs = 15000 },

    -- Exam kinds, and the minutes a failed exam waits before it can be sat again (0 = no wait).
    Kinds = {
        { key = 'quiz', RetakeMinutes = 60 },
        { key = 'midterm', RetakeMinutes = 1440 },
        { key = 'final', RetakeMinutes = 4320 },
        { key = 'project', RetakeMinutes = 1440 },
        { key = 'scholarship', RetakeMinutes = 10080 },
    },
    RetakeAfterPass = true,    -- a passed exam may be sat again to raise the grade; XP comes only once

    -- What the student does while writing.
    Presentation = {
        Enabled = true,
        FreezePlayer = true,
        Animation = { Dict = 'missheistdockssetup1clipboard@base', Name = 'base', Flag = 49 },
        Props = {
            { Model = 'prop_notepad_01', Bone = 18905, Offset = vec3(0.1, 0.02, 0.05), Rotation = vec3(10.0, 0.0, 0.0) },
            { Model = 'prop_pencil_01', Bone = 58866, Offset = vec3(0.11, -0.02, 0.001), Rotation = vec3(-120.0, 0.0, 0.0) },
        },
    },
}
