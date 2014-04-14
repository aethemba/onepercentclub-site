App.Project.reopen({
//    url: "projects",

    deadline: DS.attr('date'),
    amount_asked: DS.attr('number', {defaultValue: 0}),
    amount_donated: DS.attr('number'),
    amount_needed: DS.attr('number'),

    story: DS.attr('string'),

    maxAmountAsked: Ember.computed.lte('amount_asked', 1000000),
    minAmountAsked: Ember.computed.gte('amount_asked', 250),

    task_count: DS.attr('number'),

    isFunding: Em.computed.equal('status.id', '5'),

    isStatusCampaign: Em.computed.equal('status.id', '5'),
    isStatusCompleted: Em.computed.equal('status.id', '7')
}
);

App.MyProject.reopen({
    image: DS.attr('image'),
    video: DS.attr('string'),

    init: function () {
        this._super();

        this.validatedFieldsProperty('validGoal', this.get('requiredGoalFields'));
        this.missingFieldsProperty('missingFieldsGoal', this.get('requiredGoalFields'));
    },

    valid: function(){
        return (this.get('') && this.get('validPitch') && this.get('validGoal'));
    }.property('validStory', 'validPitch', 'validGoal'),

    requiredStoryFields: ['description', 'goal', 'destination_impact'],
    requiredGoalFields: ['amount_asked', 'deadline', 'maxAmountAsked', 'minAmountAsked'],
    requiredPitchFields: ['title', 'pitch', 'image', 'theme', 'tags.length', 'country', 'latitude', 'longitude'],

    friendlyFieldNames: {
        'title' : 'Title',
        'pitch': 'Description',
        'image' : 'Image',
        'theme' : 'Theme',
        'tags.length': 'Tags',
        'deadline' : 'Deadline',
        'country' : 'Country',
        'description': 'Why, what and how',
        'goal' : 'Goal',
        'destination_impact' : 'Destination impact'
    }

});

App.ProjectPreview.reopen({
    deadline: DS.attr('date'),
    amount_asked: DS.attr('number', {defaultValue: 0}),
    amount_donated: DS.attr('number'),
    amount_needed: DS.attr('number')
});