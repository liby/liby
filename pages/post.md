- Drafts
	- {{query (and (page-property type Post) (not (page-property status DONE)))}}
	  query-properties:: [:page]
	  query-sort-by:: page
	  query-sort-desc:: true
- Published
	- {{query (and (page-property type Post) (page-property status DONE))}}
	  query-properties:: [:page]
	  query-table:: false
	  query-sort-by:: page
	  query-sort-desc:: true