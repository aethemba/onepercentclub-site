var get = Ember.get, set = Ember.set;

DS.DRF2Serializer = DS.Serializer.extend({

    init: function() {
        this._super();
        this.transforms['array'] = {
            fromJSON: function(serialized) {
                return Ember.none(serialized) ? null : eval(serialized);
            },
            toJSON: function(deserialized) {
                return Ember.none(deserialized) ? null : deserialized.toJSON();
            }
        }
    }
});


DS.DRF2Adapter = DS.RESTAdapter.extend({

    /*
     Use a custom serializer for DRF2.
     */
    serializer: DS.DRF2Serializer,

    /*
     Bulk commits are not supported by this adapter.
     */
    bulkCommit: false,

    /*
     DRF2 uses the 'next' keyword for paginating results.
     */
    since: 'next',

    /*
     Changes from default:
     - don't call sideload() because DRF2 doesn't support it.
     - get results from json.results.
     */
    didFindAll: function(store, type, json) {
        var since = this.extractSince(json);

        store.loadMany(type, json['results']);

        // this registers the id with the store, so it will be passed
        // into the next call to `findAll`
        if (since) {
            store.sinceForType(type, since);
        }

        store.didUpdateAll(type);
    },

    /*
     Changes from default:
     - don't call sideload() because DRF2 doesn't support it.
     - get result from json directly.
     */
    didFindRecord: function(store, type, json, id) {
        store.load(type, id, json);
    },

    /*
     Changes from default:
     - don't call sideload() because DRF2 doesn't support it.
     - get results from json.results.
     */
    didFindQuery: function(store, type, json, recordArray) {
        recordArray.load(json['results']);
    },

    /*
     Changes from default:
     - Don't embed record within 'root' in the json.
     - Check for errors and call becameErrorRecord.
     - Add code for multipart/form-data form submission.
     */
    createRecord: function(store, type, record) {
        var root = this.rootForType(type);
        var data = this.toJSON(record, { includeId: true });

        // TODO: Create a general solution for detecting when to use multipart/form-data (i.e. detecting
        //       when there are files that need to be sent).
        if (type.toString() == "App.ProjectMediaWallPost") {
            // TODO: Implement this polyfill for older browsers:
            // https://github.com/francois2metz/html5-formdata
            var formdata = new FormData();
            Object.keys(data).forEach(function(key){
                if (data[key] !== undefined) {
                    // TODO: This won't be hardcoded when a general solution for detecting when to use
                    //       multipart/form-data is worked out.
                    if (key == 'photo') {
                        formdata.append(key, record.get('photo_file'))
                    } else {
                        formdata.append(key, data[key]);
                    }
                }
            });

            this.ajaxFormData(this.buildURL(root), "POST", {
                data: formdata,
                context: this,
                success: function(json) {
                    this.didCreateRecord(store, type, record, json);
                },
                // Make sure we parse any errors.
                error: function(xhr) {
                    this.becameErrorRecord(store, type, record, xhr);
                }
            });

        } else {
            this.ajax(this.buildURL(root), "POST", {
                data: data,
                context: this,
                success: function(json) {
                    this.didCreateRecord(store, type, record, json);
                },
                // Make sure we parse any errors.
                error: function(xhr) {
                    this.didHaveErrors(store, type, record, xhr);
                }
            });
        }

    },

    /**
     * A custom version of the ember-data ajax() method to set the hash up correctly for doing
     * a multipart/form-data submission with data generated by FormData.
     */
    ajaxFormData: function(url, type, hash) {
        hash.url = url;
        hash.type = type;
        hash.processData = false;  // tell jQuery not to process the data
        hash.contentType = false;  // tell jQuery not to set contentType
        hash.context = this;

        jQuery.ajax(hash);
     },


    /**
     * Add error text to a record.
     */
    becameErrorRecord: function(store, type, record, xhr) {
        if (xhr.status === 400) {
            var data = JSON.parse(xhr.responseText);
            store.recordWasInvalid(record, data);
        } else {
            // FIXME: recordWasError is not a function!
            store.recordWasError(record);
        }
    },

    /*
     Changes from default:
     - don't call sideload() because DRF2 doesn't support it.
     - get result from json directly.
     */
    didCreateRecord: function(store, type, record, json) {
        this.didSaveRecord(store, record, json);
    },

    /*
     Changes from default:
     - don't replace CamelCase with '_'.
     - also check for 'url' defined in the class.
     */
    rootForType: function(type) {
        if (type.url) {
            return type.url;
        }
        if (type.proto().url) {
            return type.proto().url;
        }
        // use the last part of the name as the URL
        var parts = type.toString().split(".");
        var name = parts[parts.length - 1];
        return name.toLowerCase();
    },

    /*
     Changes from default:
     - don't add 's' if the url name already ends with 's'.
     */
    pluralize: function(name) {
        if (this.plurals[name])
            return this.plurals[name];
        else if (name.charAt(name.length - 1) === 's')
            return name;
        else
            return name + 's';
    },

    /*
     Changes from default:
     - add trailing slash for lists.
     */
    buildURL: function(record, suffix) {
        var url = this._super(record, suffix);
        if (suffix === undefined && url.charAt(url.length - 1) !== '/') {
            url += '/';
        }
        return url;
    }

});

/*
 Based on hasAssociation used for belongsTo. Renamed to avoid conflicts with hasAssociation used for hasMany.
 Altered to enable embedded objects
 */
var belongsToAssociation = function(type, options, one) {
    options = options || {};

    var meta = { type: type, isAssociation: true, options: options, kind: 'belongsTo' };

    return Ember.computed(function(key, value) {
        if (arguments.length === 2) {
            return value === undefined ? null : value;
        }

        var data = get(this, 'data').belongsTo,
            store = get(this, 'store'), id;

        if (typeof type === 'string') {
            type = get(this, type, false) || get(window, type);
        }

        id = data[key];

        // start: embedded support
        if (options.embedded == true && typeof(id) !== 'string') {
            // load the object
            var obj = data[key];
            if (obj !== undefined) {
                id = obj.id;
                // Load the embedded object in store
                store.load(type, id, obj);
            }
        }
        // end: embedded support

        return id ? store.find(type, id) : null;
    }).property('data').meta(meta);
}

/*
Changes from default:
 - redefine belongsTo() with our new belongsToAssociation() function
 - belongsToAssociation is an altered copy of hasAssociation, but it would conflict with the hasAssociation
   we will be using for hasMany relations (below)
*/
DS.belongsTo = function(type, options) {
    Em.assert("The type passed to DS.belongsTo must be defined", !!type);
    return belongsToAssociation(type, options);
};

/*
  Based on hasAssociation used for hasMany. Renamed to avoid conflicts with hasAssociation used for belongsTo.
  Altered to enable embedded objects
 */
var hasManyAssociation = function(type, options) {
    options = options || {};

    var meta = { type: type, isAssociation: true, options: options, kind: 'hasMany' };

    return Ember.computed(function(key, value) {
        var data = get(this, 'data').hasMany,
            store = get(this, 'store'),
            ids, association;

        if (typeof type === 'string') {
            type = get(this, type, false) || get(window, type);
        }

        // start: embedded support
        if (options.embedded == true) {
            var items = data[key];
            // Check if there are embedded objects
            if (items !== undefined && items.length) {
                // Load the objects into the store
                store.loadMany(type, items);
                ids = [];
                // Iterate through the items to get their ids
                for (var i = 0, len = items.length; i < len; ++i) {
                    var id = items[i].id;
                    ids.push(id);
                }
                // Load the Ember objects from the store to this association
                // Since we already loaded them this won't make another server call
                association = store.findMany(type, ids);
            } else {
                association = [];
            }
        } else {
            ids = data[key];
            association = store.findMany(type, ids || [], this, meta);
        }

        // end: embedded support

        set(association, 'owner', this);
        set(association, 'name', key);

        return association;
    }).property().meta(meta);
};


/*
 Changes from default:
 - redefine hasMany() with our new hasManyAssociation() function
 - hasManyAssociation is an altered copy of hasAssociation, but it would conflict with the hasAssociation
   we will be used for belongsTo relations (above)
 */

DS.hasMany = function(type, options) {
    Ember.assert("The type passed to DS.hasMany must be defined", !!type);
    return hasManyAssociation(type, options);
};
