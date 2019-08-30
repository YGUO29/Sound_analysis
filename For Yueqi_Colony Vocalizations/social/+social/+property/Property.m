%Social.property.Property Abstract base class for all social properties
%
% Adapted from xbz.log.property.Property (Darik Gamble).
% 
%Properties have a name, a parent name (e.g., the name of the stimulus
%panel where the property originated), a full name (simply the
%concatenation of their parent name and name), an optional type, and an
%optional description. Their most important method is the get_value method,
%which accepts a single input, a column vector of data IDs (as returned by
%xbz.log.source.LogSource.get_available_data_id method, and return an
%equisize vector (or cell array) of property values.
%
%Properties subclassing xbz.log.property.Property must implement the
%get_value method. If subclass property requires user interface and/or
%saving state, subclass xbz.log.property.ComponentProperty. Use concrete
%subclasses xbz.log.property.IndexedProperty for properties whose data are
%directly indexed by trial number, xbz.log.property.DynamicProperty for
%properties whose get_value method is implemented in the parent property
%supplier.
%
%Some examples of working with log properties:
%
% nTrials = 10;
% data = rand(nTrials, 1);
% prop1 = xbz.log.property.IndexedProperty(...
%     'myprops', 'Prop1', 'trial',...
%     'First example property',  data);
% full_name_1 = prop1.FullName %Prints 'myprops.Prop1'
% prop1_trial_data = prop1.get_value([1 3 5]') %Get values for trials 1, 3 & 5
% 
% prop2 = xbz.log.property.DynamicProperty(...
%     'myprops', 'Prop2', 'trial',...
%     'Second example property',...
%     @(prop, id)randi(2, size(id)));
% prop2_trial_data = prop2.get_value([1 3 5]') %Generate random data for trials
% prop2_trial_data = prop2.get_value([1 3 5]') %Different values each time
% 
% both_props = [prop1, prop2]; %Heterogeneous array of property objects
% first_prop = findobj(both_props, 'Name', 'Prop1'); %Supports findobj
% second_prop = setdiff(both_props, first_prop); %Supports set functions


classdef Property < hgsetget & xbz.util.HeterogeneousHandle
    properties 
        Name
        ParentName
        FullName        % = ParentName.Name
        Type            
        
        Description = ''    %Optional property description
    end
    properties
        %AutoSelectMode is used to hint whether property can be
        %autoselected
        %   on            - Allowed to be autoselected
        %   off           - Never autoselect
        %   always        - Always autoselect
        %   defaultonly   - Autoselect only if nothing else available
        AutoSelectMode = 'on'
        
        %AutoSortOrder is used to determine in what order properties
        %are sorted if multiple properties are selected
        AutoSortOrder = 0
    end
    
    methods
        function self = Property (parentname, name, type, desc, varargin)
            if ~nargin, return, end %Allow 0 input args for array preallocation
            
            self.Name = name;
            self.ParentName = parentname;
            self.Type = type;
            self.refresh_full_name();
            self.Description = desc;
            
            if nargin>4, set(self, varargin{:}); end
        end
        function val = get_value (self, id) %#ok<INUSD,STOUT>
            %get_value accepts a nKeys*1 of primary key values, and should
            %return a nKeys*n array or cell array of data. n is usually 1. 
            error('xbz:badproperty', 'get_value not implemented');
        end
    end
    methods (Sealed)
        function refresh_full_name (self)
            self.FullName = [self.ParentName '.' self.Name];
        end
        function varargout = set (h, varargin)
            [varargout{1:nargout}] = set@hgsetget(h, varargin{:});
        end
        function varargout = get (h, varargin)
            [varargout{1:nargout}] = get@hgsetget(h, varargin{:});
        end
        function x = get_values (h, id, return_mode)
            %xbz.log.property.Property.get_value only supports scalar objects
            %This works on arrays of propertyhandles
            %
            %Returns a structure whose fieldnames are the condition names, and whose
            %values are the logged values at index IDX
            
            %Note that an empty struct is returned if h is empty prop array
            x = struct;
            
            if ~isempty(h)
                for i = 1:length(h)
                    x.(h(i).Name) = h(i).get_value(id);
                end    
            end            

            if nargin<3, return, end %Default to struct
            switch return_mode
                case 'struct'
                    %Do nothing
                case 'table'
                    x = struct2table(x);
                case 'cell'
                    x = struct2cell(x)';
                case 'numeric'
                    x = struct2cell(x);
                    assert(~any(cellfun(@ischar, x)),... %Prevent misleading "CAT arguments dimensions are not consistent" error
                        'xb3:datalogprop:strvalsnum', 'Cannot return a numeric array -- one or more fields contain char data');
                    x = [x{:}];
                        
            end
        end
        function h = find_varying (h, id)
            %For input array of handles H, returns a subset containing
            %the properties that vary over the set of data IDs id
            if isempty(id)
                h = h([]); 
                return
            end
            
            is_varied = false(size(h));
            vals = cell(1, length(h));
            for i = 1:length(h)
                v = h(i).get_value(id);

                try
                    [unq_idx, ~, ~, ~, raw_idx] = xbz.util.uniqueidx(v, 'rows', 'equalnans');
                catch E
                    %xbz.util.uniqueidx will fail on cell arrays of mixed length vectors
                    %or cell arrays of empty vectors
                    %treat those proeprties as not varying
                    if strcmp(E.identifier, 'MATLAB:sortrows:nonScalarCell')
                        unq_idx = 1;
                    elseif iscell(v) ...
                            && (    length(unique(cellfun(@length, v))) > 1     ...
                                 || all(cellfun(@isempty, v))               );
                        %Just ignore this property
                        unq_idx = 1;
                    else
                        %unexpected error
                        rethrow(E);
                    end
                end
                
                if length(unq_idx) > 1;
                    is_varied(i) = true;
                    %Store transformed values so we can check for redundant properties (below) 
                    %without worrying about data class, number of columns, etc.
                    vals{i} = raw_idx;       
                end
            end
            h = h(is_varied);
            
            %Check for redundant properties
            vals = [vals{is_varied}];
            [~, i] = unique(vals', 'rows');
            h = h(i);
        end
        function p = find_by_name (h, search_string, varargin)
            opts = struct(...
                'SearchField'           ,'Name'         ,... %Or 'FullName' or 'ParentName'
                'InvertMatches'         ,false          ,... %Return props that DON'T match
                'AssertScalar'          ,true           );   %Throw error if not exactly one property found
            
            opts = xbz.util.parse_parameters(opts, varargin{:});
            
            all_prop_names = {h.(opts.SearchField)};
            idx = regexp(all_prop_names, search_string);
            idx = ~cellfun(@isempty, idx);
            if opts.InvertMatches
                idx = ~idx;
            end
                
            if opts.AssertScalar
                n = sum(idx);
                assert(n>0, 'xbz:propselector:findprop:foundnone',...
                    'Expected to find 1 property "%s", found none.',...
                        search_string);

                assert(n<2, 'xbz:propselector:findprop:foundmany',...
                    'Expected to find 1 property "%s", found %d: %s',...
                        search_string, n, xbz.util.cslstr(all_prop_names(idx)));
            end
                   
            p = h(idx);

        end
        function p = ez_find_by_name (allprops, orig_name)
            %Like find_by_name, but less rigorous
            %Designed for user-facing code where we want to find a single
            %property by name
            name = ['(?i)' orig_name]; %Force ignore case
            
            p = allprops.find_by_name(name,...
                'AssertScalar'      ,false      );
            
            if isempty(p)
                %Try searching full name
                 p = allprops.find_by_name(name,...
                    'AssertScalar'      ,false          ,...
                    'SearchField'       ,'FullName'     );
            end
            if length(p)==1, return, end
            if isempty(p)
                error('xbz:props:ezfoundnone',...
                    'Unable to locate property by string "%s"', name);
            end
            if length(p) > 1
                %Check for more exact match
                
                error('xbz:props:ezfoundmany',...
                    'Property string "%s" matches multiple properties: %s',...
                        name, xbz.util.cslstr({p.FullName}));
            end
        end
    end
end
        
                