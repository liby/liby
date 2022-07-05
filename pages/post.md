- Draft
	- {{query (and (page-property type Post) (not (page-property status DONE)))}}
	  query-properties:: [:page]
- Published
	- {{query (and (page-property type Post) (page-property status DONE))}}
	  query-properties:: [:page]
	  query-table:: false