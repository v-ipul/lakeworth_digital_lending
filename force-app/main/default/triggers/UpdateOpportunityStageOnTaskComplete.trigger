trigger UpdateOpportunityStageOnTaskComplete on Task (after insert, after update) {
/* Set<Id> oppIds = new Set<Id>();
    Boolean taskCompleted = true;

    // Gather Opportunity IDs from related Tasks and check task completion status
    for (Task t : Trigger.new) {
        if (t.WhatId != null && String.valueOf(t.WhatId).startsWith('006')) { // '006' prefix = Opportunity
            oppIds.add(t.WhatId);
        }

        // Check if the task is completed, if not, add error
        if (t.Status != 'Completed') {
            taskCompleted = false;
            t.addError('Please complete the task before proceeding.');
        }
    }

    if (oppIds.isEmpty() || !taskCompleted) return;

    // Define the required task subjects
    Set<String> requiredSubjects = new Set<String>{
        'Interview Prospect',
        'Request Financials',
        'Research Customer',
        'Perform Initial Go / No Go',
        'Complete CAT Tool (IRR, Hold Limits)'
    };

    // Map to track which Opportunity has which completed tasks
    Map<Id, Set<String>> oppToCompletedTasks = new Map<Id, Set<String>>();

    // Query all relevant tasks
    List<Task> relatedTasks = [
        SELECT WhatId, Subject, Status 
        FROM Task 
        WHERE WhatId IN :oppIds 
        AND Subject IN :requiredSubjects
    ];

    for (Task t : relatedTasks) {
        if (t.Status == 'Completed') {
            if (!oppToCompletedTasks.containsKey(t.WhatId)) {
                oppToCompletedTasks.put(t.WhatId, new Set<String>());
            }
            oppToCompletedTasks.get(t.WhatId).add(t.Subject);
        }
    }

    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    for (Id oppId : oppToCompletedTasks.keySet()) {
        Set<String> completed = oppToCompletedTasks.get(oppId);
        if (completed.containsAll(requiredSubjects)) {
            oppsToUpdate.add(new Opportunity(Id = oppId, StageName = 'Submitted'));
        }
    }

    if (!oppsToUpdate.isEmpty()) {
        update oppsToUpdate;
    }*/
}