App.AnimateProgressMixin = Em.Mixin.create({
    didInsertElement: function(){
        var donated = this.get('controller.campaign.money_donated');
        var asked = this.get('controller.campaign.money_asked');
        this.$('.slider-progress').css('width', '0px');
        var width = 0;
        if (asked > 0) {
            width = 100 * donated / asked;
            width += '%';
        }
        this.$('.slider-progress').animate({'width': width}, 3000);
    }
});

App.ProjectMembersView = Em.View.extend({
    templateName: 'project_members'
});

App.ProjectSupporterView = Em.View.extend({
    templateName: 'project_supporter',
    tagName: 'li',
    didInsertElement: function(){
        this.$('a').popover({trigger: 'hover', placement: 'top'})
    }
});

App.ProjectSupporterListView = Em.View.extend({
    templateName: 'project_supporter_list'
});

App.ProjectDonationView = Em.View.extend({
    templateName: 'project_donation'
});

App.ProjectListView = Em.View.extend(App.ScrollInView, {
    templateName: 'project_list'
});

App.ProjectPreviewView = Em.View.extend(App.AnimateProgressMixin, {
    templateName: 'project_preview'
});


App.ProjectSearchFormView = Em.View.extend({
    templateName: 'project_search_form'
});


App.ProjectPlanView = Em.View.extend(App.ScrollInView, {
    templateName: 'project_plan',

    staticMap: function(){
        var latlng = this.get('controller.latitude') + ',' + this.get('controller.longitude');
        return "http://maps.googleapis.com/maps/api/staticmap?" + latlng + "&zoom=8&size=600x300&maptype=roadmap" +
            "&markers=color:pink%7Clabel:P%7C" + latlng + "&sensor=false";
    }.property('latitude', 'longitude')
});


App.ProjectView = Em.View.extend(App.AnimateProgressMixin, {
    templateName: 'project',

    didInsertElement: function(){
        this._super();
        this.$('.tags').popover({trigger: 'hover', placement: 'top', width: '100px'});
    }
});


/* Form Elements */

App.ProjectOrderList = [
    {value: 'title', title: gettext("title")},
    {value: 'money_needed', title: gettext("money needed")},
    {value: 'deadline', title: gettext("deadline")}
];

App.ProjectOrderSelectView = Em.Select.extend({
    content: App.ProjectOrderList,
    optionValuePath: "content.value",
    optionLabelPath: "content.title"
});

App.ProjectPhaseList = [
    {value: 'plan', title: gettext("Writing Plan")},
    {value: 'campaign', title: gettext("Campaign")},
    {value: 'act', title: gettext("Act")},
    {value: 'results', title: gettext("Results")},
    {value: 'realized', title: gettext("Realised")}
];

App.ProjectPhaseSelectView = Em.Select.extend({
    content: App.ProjectPhaseList,
    optionValuePath: "content.value",
    optionLabelPath: "content.title",
    prompt: gettext("Pick a phase")

});



/*
 Project Manage Views
 */


App.MyProjectListView = Em.View.extend({
    templateName: 'my_project_list'
});

App.MyProjectView = Em.View.extend({
    templateName: 'my_project'

});


// Project Pitch Phase

App.MyPitchNewView = Em.View.extend({
    templateName: 'my_pitch_new'
});

App.MyProjectPitchView = Em.View.extend({
    templateName: 'my_project_pitch'

});

App.MyProjectPitchIndexView = Em.View.extend({
    templateName: 'my_pitch_index'

});

App.MyProjectPitchBasicsView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_pitch_basics'
});

App.MyProjectPitchMediaView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_media'
});

App.MyProjectPitchLocationView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_location'
});


App.MyProjectPitchSubmitView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_pitch_submit'
});



// Project Plan phase

App.MyProjectPlanView = Em.View.extend({
    templateName: 'my_project_plan'
});

App.MyProjectPlanIndexView = Em.View.extend({
    templateName: 'my_project_plan_index'
});

App.MyProjectPlanBasicsView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_basics'
});

App.MyProjectPlanDescriptionView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_description'
});

App.MyProjectPlanLocationView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_location'
});

App.MyProjectPlanMediaView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_media'
});

App.MyProjectPlanOrganisationView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_organisation'
});

App.MyProjectPlanLegalView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_legal'
});

App.MyProjectPlanAmbassadorsView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_ambassadors'
});

App.MyProjectPlanBankView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_bank'
});

App.MyProjectPlanBudgetView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_budget'
});

App.MyProjectPlanCampaignView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_campaign'
});

App.MyProjectPlanSubmitView = Em.View.extend(App.PopOverMixin, {
    templateName: 'my_project_plan_submit'
});



// See/Use App.DatePicker
App.DatePickerValue = Ember.TextField.extend({
    type: 'hidden',
    valueBinding: "parentView.value"
});

// See/Use App.DatePicker
App.DatePickerWidget = Ember.TextField.extend({

    dateBinding: "parentView.value",
    configBinding: "parentView.config",

    didInsertElement: function(){
        var config = this.get('config');
        this.$().datepicker(config);
        this.$().datepicker('setDate', this.get('date'));
    },

    change: function(){
        this.set('date', this.$().datepicker('getDate'));
    }
});

// This renders a TextField with the localized date.
// On click it will use jQuery UI date picker dialog so the user can select a date.
// valueBinding should bind to a  DS.attr('date') property of an Ember model.
App.DatePicker = Ember.ContainerView.extend({
    config: {changeMonth: true, changeYear: true, yearRange: "c-100:c+10"},
    childViews: [App.DatePickerValue, App.DatePickerWidget]
});

App.CustomDatePicker = App.DatePicker.extend({
    init: function(){
        this._super();
        if (this.get("minDate") != undefined) {
            this.config.minDate = this.get("minDate");
        }
        if (this.get("maxDate") != undefined) {
            this.config.maxDate = this.get("maxDate");
        }
    }
});
