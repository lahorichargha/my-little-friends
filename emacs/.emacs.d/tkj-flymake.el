;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Java flymake support using the Eclipse compiler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'flymake)

;; setting the class path
(setq tkj-dir "/home/torstein/src/p4/projects/poc/inpage-poc/")
(setq tkj-classpath
      (concat
       tkj-dir "viziwyg-ws/target/classes:"
       tkj-dir "viziwyg-common/target/classes:"
       tkj-dir "viziwyg-presentation/target/classes"))

(defun tkj-read-jar(pFile)
  (setq tkj-classpath
        (concat tkj-classpath ":" pFile)))

(require 'find-lisp)
(mapc 'tkj-read-jar
      (find-lisp-find-files "/opt/escenic/assemblytool/dist/.work/publication-plugin/WEB-INF/lib/"
                            "\\.jar$"))
(mapc 'tkj-read-jar
      (find-lisp-find-files "/opt/escenic/assemblytool/dist/.work/ear/lib"
                            "\\.jar$"))


(defun flymake-java-ecj-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'jde-ecj-create-temp-file))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))

    ;; if you've downloaded ecj from eclipse.org, then use these two lines:
    ;;    (list "java" (list "-jar" 
    ;;                       "/usr/share/java/ecj.jar"

    ;; if installing it with DEB packages,or by some other means
    ;; giving you the ecj BASH script front end, simply use this line
    ;; instead:
    (list "ecj" (list 
                 "-Xemacs" 
                 "-d" "/dev/null" 
                 "-source" "1.6"
                 "-target" "1.6"
                 "-sourcepath" (car tkj-sourcepath)
                 "-classpath" 
                 tkj-classpath
                 local-file))))

(defun flymake-java-ecj-cleanup ()
  "Cleanup after `flymake-java-ecj-init' -- delete temp file and dirs."
  (flymake-safe-delete-file flymake-temp-source-file-name)
  (when flymake-temp-source-file-name
    (flymake-safe-delete-directory
     (file-name-directory flymake-temp-source-file-name))))

(defun jde-ecj-create-temp-file (file-name prefix)
  "Create the file FILE-NAME in a unique directory in the temp directory."
  (file-truename (expand-file-name
                  (file-name-nondirectory file-name)
                  (expand-file-name  (int-to-string (random)) 
                                     (flymake-get-temp-dir)))))

(push '(".+\\.java$" flymake-java-ecj-init 
        flymake-java-ecj-cleanup) flymake-allowed-file-name-masks)

(push '("\\(.*?\\):\\([0-9]+\\): error: \\(.*?\\)\n" 1 2 nil 2 3
        (6 compilation-error-face)) compilation-error-regexp-alist)

(push '("\\(.*?\\):\\([0-9]+\\): warning: \\(.*?\\)\n" 1 2 nil 1 3
        (6 compilation-warning-face)) compilation-error-regexp-alist)

(defun credmp/flymake-display-err-minibuf () 
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info
                                      flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count)
                                                  line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count)
                                                       line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count)
                                                  line-err-info-list))))
          (message "[%s] %s" line text)
          )
        )
      (setq count (1- count)))))


(defun tkj-show-previous-error ()
  (interactive)
  (flymake-goto-prev-error)
  (credmp/flymake-display-err-minibuf))

(defun tkj-show-next-error ()
  (interactive)
  (flymake-goto-next-error)
  (credmp/flymake-display-err-minibuf))


;; (setq tkj-classpath (list "/home/torstein/src/p4/escenic/plugins/dashboard/trunk/dashboard-core/target/classes:/home/torstein/src/p4/escenic/plugins/dashboard/trunk/dashboard-presentation/target:/home/torstein/src/p4/escenic/plugins/dashboard/trunk/dashboard-community/target:/home/torstein/src/p4/escenic/plugins/dashboard/trunk/dashboard-webapp/target:/home/torstein/src/p4/escenic/plugins/dashboard/trunk/dashboard-forum/target:/home/torstein/src/p4/escenic/plugins/viziwyg/trunk/viziwyg-ws/target/classes:/home/torstein/src/p4/escenic/plugins/viziwyg/trunk/viziwyg-common/target/classes:/home/torstein/src/p4/escenic/plugins/viziwyg/trunk/viziwyg-presentation/target/classes:/home/torstein/.emacs.d/flymake-java-lib/xstream-1.3.1.jar:/home/torstein/.emacs.d/flymake-java-lib/xsdlib-2009.1.jar:/home/torstein/.emacs.d/flymake-java-lib/xpp3_min-1.1.4c.jar:/home/torstein/.emacs.d/flymake-java-lib/xom-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/xmlrpc-server-3.1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/xmlrpc-common-3.1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/xmlrpc-client-3.1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/xml-resolver-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/xmlParserAPIs-2.6.2.jar:/home/torstein/.emacs.d/flymake-java-lib/xmlParserAPIs-2.2.1.jar:/home/torstein/.emacs.d/flymake-java-lib/xml-editor-shared.jar:/home/torstein/.emacs.d/flymake-java-lib/xml-editor-shared-2.1.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/xml-editor-phoenix-2.1.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/xml-editor-core-2.1.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/xml-apis-1.3.04.jar:/home/torstein/.emacs.d/flymake-java-lib/xercesImpl-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/xalan-2.7.0.jar:/home/torstein/.emacs.d/flymake-java-lib/wstx-asl-3.2.7.jar:/home/torstein/.emacs.d/flymake-java-lib/ws-commons-util-1.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/winpack-3.8.2.jar:/home/torstein/.emacs.d/flymake-java-lib/widget-framework-core-tags-1.10.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/widget-framework-community-tags-1.10.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/widget-framework-common-1.10.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/velocity-tools-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/velocity-1.5.jar:/home/torstein/.emacs.d/flymake-java-lib/twitter4j-core-2.2.2.jar:/home/torstein/.emacs.d/flymake-java-lib/twelvemonkeys-servlet-2.3.3-ece.jar:/home/torstein/.emacs.d/flymake-java-lib/twelvemonkeys-core-2.3.jar:/home/torstein/.emacs.d/flymake-java-lib/trove4j-2.1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/timingframework-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/tika-core-0.8.jar:/home/torstein/.emacs.d/flymake-java-lib/tango-icon-theme-0.8.0.jar:/home/torstein/.emacs.d/flymake-java-lib/swingx-0.9.2.jar:/home/torstein/.emacs.d/flymake-java-lib/swing-worker-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/studio-webstart-engine-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/studio-webstart-bootstrap-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/studio-swing-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/studio-core-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/studio-api-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/struts-core-1.2.9.jar:/home/torstein/.emacs.d/flymake-java-lib/struts-1.2.9.jar:/home/torstein/.emacs.d/flymake-java-lib/storage-file-3.2-escenic.jar:/home/torstein/.emacs.d/flymake-java-lib/stax-api-1.0-2.jar:/home/torstein/.emacs.d/flymake-java-lib/stax-api-1.0.1.jar:/home/torstein/.emacs.d/flymake-java-lib/standard-1.1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-web-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-support-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-jdbc-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-hibernate3-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-dao-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-core-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-context-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-beans-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spring-aop-2.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/spellchecker-1.3.jar:/home/torstein/.emacs.d/flymake-java-lib/solr-solrj-1.4.0.jar:/home/torstein/.emacs.d/flymake-java-lib/solr-core-1.4.0.jar:/home/torstein/.emacs.d/flymake-java-lib/solr-commons-csv-1.4.0.jar:/home/torstein/.emacs.d/flymake-java-lib/slf4j-simple-1.5.6.jar:/home/torstein/.emacs.d/flymake-java-lib/slf4j-log4j12-1.5.8.jar:/home/torstein/.emacs.d/flymake-java-lib/slf4j-jdk14-1.5.5.jar:/home/torstein/.emacs.d/flymake-java-lib/slf4j-api-1.5.8.jar:/home/torstein/.emacs.d/flymake-java-lib/slf4j-api-1.5.5.jar:/home/torstein/.emacs.d/flymake-java-lib/silk-1.3.jar:/home/torstein/.emacs.d/flymake-java-lib/runtime-license-2.jar:/home/torstein/.emacs.d/flymake-java-lib/runtime-0.4.1.5.jar:/home/torstein/.emacs.d/flymake-java-lib/rome-fetcher-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/rome-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/resolvers-commons-httpclient-3.2-escenic.jar:/home/torstein/.emacs.d/flymake-java-lib/relaxngDatatype-20020414.jar:/home/torstein/.emacs.d/flymake-java-lib/recaptcha4j-0.0.7.jar:/home/torstein/.emacs.d/flymake-java-lib/quartz-1.5.1.jar:/home/torstein/.emacs.d/flymake-java-lib/poll-presentation-2.1.3.0.jar:/home/torstein/.emacs.d/flymake-java-lib/poll-core-2.1.3.0.jar:/home/torstein/.emacs.d/flymake-java-lib/plugin-xmlEditor.jar:/home/torstein/.emacs.d/flymake-java-lib/plugins-common-core-1.1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/plugin-menuEditor.jar:/home/torstein/.emacs.d/flymake-java-lib/phoenix-core-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/persistence-api-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/oro-2.0.8.jar:/home/torstein/.emacs.d/flymake-java-lib/opensearch-0.1.jar:/home/torstein/.emacs.d/flymake-java-lib/openid4java-nodeps-0.9.5.jar:/home/torstein/.emacs.d/flymake-java-lib/openid4java-consumer-0.9.5.jar:/home/torstein/.emacs.d/flymake-java-lib/nekohtml-1.9.7.jar:/home/torstein/.emacs.d/flymake-java-lib/model-core-1.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/metadata-extractor-2.4.1-ece-2.jar:/home/torstein/.emacs.d/flymake-java-lib/menu-editor-taglib-2.0.6.0.jar:/home/torstein/.emacs.d/flymake-java-lib/menu-editor-phoenix-2.0.6.0.jar:/home/torstein/.emacs.d/flymake-java-lib/menu-editor-core-2.0.6.0.jar:/home/torstein/.emacs.d/flymake-java-lib/martha-edf-1.2.3136.jar:/home/torstein/.emacs.d/flymake-java-lib/martha-core-lib-1.2.3136.jar:/home/torstein/.emacs.d/flymake-java-lib/martha-core-1.2.3136.jar:/home/torstein/.emacs.d/flymake-java-lib/mail-1.4.jar:/home/torstein/.emacs.d/flymake-java-lib/lucy-core-4.1.6.0.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-spellchecker-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-snowball-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-queries-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-misc-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-memory-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-highlighter-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-core-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/lucene-analyzers-2.9.1.jar:/home/torstein/.emacs.d/flymake-java-lib/log4j-1.2.14.jar:/home/torstein/.emacs.d/flymake-java-lib/jxbrowser-2.9.29006.jar:/home/torstein/.emacs.d/flymake-java-lib/junit-dep-4.4.jar:/home/torstein/.emacs.d/flymake-java-lib/jtidy-r918-dev.jar:/home/torstein/.emacs.d/flymake-java-lib/jta-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jstl-1.1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/jsr311-api-1.1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jsr107cache-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/json-lib-1.0-jdk15.jar:/home/torstein/.emacs.d/flymake-java-lib/json-20080701.jar:/home/torstein/.emacs.d/flymake-java-lib/joda-time-1.6.jar:/home/torstein/.emacs.d/flymake-java-lib/jmock-junit4-2.5.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jmock-2.5.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jldap-4.3.jar:/home/torstein/.emacs.d/flymake-java-lib/jing-20091111.jar:/home/torstein/.emacs.d/flymake-java-lib/jettison-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jersey-server-1.8.jar:/home/torstein/.emacs.d/flymake-java-lib/jersey-server-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/jersey-json-1.8.jar:/home/torstein/.emacs.d/flymake-java-lib/jersey-core-1.8.jar:/home/torstein/.emacs.d/flymake-java-lib/jersey-core-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/jersey-client-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/jersey-atom-abdera-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/jdom-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/jcl-over-slf4j-1.5.5.jar:/home/torstein/.emacs.d/flymake-java-lib/jcaptcha-all-1.0-RC5.jar:/home/torstein/.emacs.d/flymake-java-lib/jaxen-1.1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jaxb-impl-2.2.3-1.jar:/home/torstein/.emacs.d/flymake-java-lib/jaxb-impl-2.1.9.jar:/home/torstein/.emacs.d/flymake-java-lib/jaxb-api-2.2.2.jar:/home/torstein/.emacs.d/flymake-java-lib/jaxb-api-2.1.jar:/home/torstein/.emacs.d/flymake-java-lib/javassist-3.9.0.GA.jar:/home/torstein/.emacs.d/flymake-java-lib/jai_imageio-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jai_core-1.1.3.jar:/home/torstein/.emacs.d/flymake-java-lib/jai_codec-1.1.3.jar:/home/torstein/.emacs.d/flymake-java-lib/jackson-xc-1.7.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jackson-mapper-asl-1.7.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jackson-mapper-asl-1.4.3.jar:/home/torstein/.emacs.d/flymake-java-lib/jackson-jaxrs-1.7.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jackson-core-asl-1.7.1.jar:/home/torstein/.emacs.d/flymake-java-lib/jackson-core-asl-1.4.3.jar:/home/torstein/.emacs.d/flymake-java-lib/isorelax-20041111.jar:/home/torstein/.emacs.d/flymake-java-lib/isorelax-20030108.jar:/home/torstein/.emacs.d/flymake-java-lib/inpage-ws-dnd-poc.jar:/home/torstein/.emacs.d/flymake-java-lib/inpage-presentation-trunk-SNAPSHOT.jar:/home/torstein/.emacs.d/flymake-java-lib/inpage-presentation-dnd-poc.jar:/home/torstein/.emacs.d/flymake-java-lib/inpage-common-dnd-poc.jar:/home/torstein/.emacs.d/flymake-java-lib/indexer-core-1.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/httpcache4j-storage-api-3.2-escenic.jar:/home/torstein/.emacs.d/flymake-java-lib/httpcache4j-core-3.2-escenic.jar:/home/torstein/.emacs.d/flymake-java-lib/httpcache4j-api-3.2-escenic.jar:/home/torstein/.emacs.d/flymake-java-lib/htmlparser-1.6.jar:/home/torstein/.emacs.d/flymake-java-lib/hsqldb-1.8.0.7.jar:/home/torstein/.emacs.d/flymake-java-lib/hibernate-ehcache-3.3.2.GA.jar:/home/torstein/.emacs.d/flymake-java-lib/hibernate-core-3.3.2.GA.jar:/home/torstein/.emacs.d/flymake-java-lib/hibernate-commons-annotations-3.3.0.ga.jar:/home/torstein/.emacs.d/flymake-java-lib/hibernate-annotations-3.3.0.ga.jar:/home/torstein/.emacs.d/flymake-java-lib/hamcrest-library-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/hamcrest-core-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/guava-r07.jar:/home/torstein/.emacs.d/flymake-java-lib/geronimo-stax-api_1.0_spec-1.0.1.jar:/home/torstein/.emacs.d/flymake-java-lib/forum-syndication-3.0.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/forum-presentation-3.0.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/forum-core-3.0.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/forms-1.2.1.jar:/home/torstein/.emacs.d/flymake-java-lib/filters-2.0.235.jar:/home/torstein/.emacs.d/flymake-java-lib/fcp-1.2.3136.jar:/home/torstein/.emacs.d/flymake-java-lib/facebook-java-api-schema-3.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/facebook-java-api-annotation-processor-3.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/facebook-java-api-3.0.2.jar:/home/torstein/.emacs.d/flymake-java-lib/ezmorph-1.0.1.jar:/home/torstein/.emacs.d/flymake-java-lib/escenic-instance-class.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-webservice-api-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-webkit-2.9.29006.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-taglib-trunk-SNAPSHOT.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-taglib-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-taglib-5.3.2.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-syndication-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-servletsupport-trunk-SNAPSHOT.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-servletsupport-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-servletsupport-5.3.2.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-search-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-presentation-trunk-SNAPSHOT.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-presentation-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-presentation-5.3.2.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-ldap-migration-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-ie-2.9.29006.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-core-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-config-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/engine-bootstrap-config.jar:/home/torstein/.emacs.d/flymake-java-lib/ehcache-1.5.0.jar:/home/torstein/.emacs.d/flymake-java-lib/ehcache-1.2.4.jar:/home/torstein/.emacs.d/flymake-java-lib/ehcache-1.2.3.jar:/home/torstein/.emacs.d/flymake-java-lib/dwr-2.0.5.jar:/home/torstein/.emacs.d/flymake-java-lib/dtdparser.jar:/home/torstein/.emacs.d/flymake-java-lib/dspace-geoip-1.2.3.jar:/home/torstein/.emacs.d/flymake-java-lib/dom4j-1.6.1.jar:/home/torstein/.emacs.d/flymake-java-lib/diffmodule-1.2.3136.jar:/home/torstein/.emacs.d/flymake-java-lib/deltaxml-1.2.3136.jar:/home/torstein/.emacs.d/flymake-java-lib/dashboard-presentation-trunk-SNAPSHOT.jar:/home/torstein/.emacs.d/flymake-java-lib/dashboard-presentation-1.0.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/dashboard-core-1.0.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/concurrent-1.3.4.jar:/home/torstein/.emacs.d/flymake-java-lib/community-presentation-trunk-SNAPSHOT.jar:/home/torstein/.emacs.d/flymake-java-lib/community-presentation-3.6.1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/community-phoenix-3.6.1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/community-core-3.6.1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/community-common-3.6.1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/common-vdf-1.5.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/common-util-1.5.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-vfs-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-validator-1.3.1.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-pool-1.3.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-logging-1.1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-logging-1.0.4.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-lang-2.3.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-io-1.4.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-httpclient-3.1.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-fileupload-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-fileupload-1.2.1.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-fileupload-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-digester-1.6.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-dbcp-1.2.2.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-dbcp-1.2.1.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-csv-1.0-SNAPSHOT-r609327.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-collections-3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-codec-1.4.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-codec-1.3.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-codec-1.2.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-beanutils-1.8.0.jar:/home/torstein/.emacs.d/flymake-java-lib/commons-beanutils-1.7.0.jar:/home/torstein/.emacs.d/flymake-java-lib/common-nursery-servlet-trunk-SNAPSHOT.jar:/home/torstein/.emacs.d/flymake-java-lib/common-nursery-servlet-1.5.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/common-nursery-servlet-1.5.2.2.jar:/home/torstein/.emacs.d/flymake-java-lib/common-nursery-1.5.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/client-core-1.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/client-api-1.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/classification-syndication-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/classification-core-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/classification-backends-database-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/classification-api-5.3.3.2.jar:/home/torstein/.emacs.d/flymake-java-lib/classes.jar:/home/torstein/.emacs.d/flymake-java-lib/cglib-nodep-2.1_3.jar:/home/torstein/.emacs.d/flymake-java-lib/bitlyj-2.0.0.jar:/home/torstein/.emacs.d/flymake-java-lib/backport-util-concurrent-3.1.jar:/home/torstein/.emacs.d/flymake-java-lib/axiom-impl-1.2.5.jar:/home/torstein/.emacs.d/flymake-java-lib/axiom-api-1.2.5.jar:/home/torstein/.emacs.d/flymake-java-lib/asm-3.1.jar:/home/torstein/.emacs.d/flymake-java-lib/appframework-1.03-svn.jar:/home/torstein/.emacs.d/flymake-java-lib/apache-solr-solrj-1.4.0.jar:/home/torstein/.emacs.d/flymake-java-lib/apache-solr-dataimporthandler-1.4.0.jar:/home/torstein/.emacs.d/flymake-java-lib/apache-solr-core-1.4.0.jar:/home/torstein/.emacs.d/flymake-java-lib/aopalliance-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/antlr-2.7.6.jar:/home/torstein/.emacs.d/flymake-java-lib/activation-1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/activation-1.1.1.jar:/home/torstein/.emacs.d/flymake-java-lib/abdera-parser-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/abdera-i18n-1.0.jar:/home/torstein/.emacs.d/flymake-java-lib/abdera-core-1.0.jar:/opt/tomcat/lib/servlet-api.jar" ))
(setq tkj-sourcepath (list ""))

(defun my-java-flymake-mode-hook ()
  (flymake-mode)
  (define-key c-mode-base-map "\C-c\C-n" 'tkj-show-next-error)
  (define-key c-mode-base-map "\C-c\C-p" 'tkj-show-previous-error)
)
(add-hook 'c-mode-common-hook 'my-java-flymake-mode-hook)
