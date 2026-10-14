# URGENT — lean HARD FORCE PUSH (DimCue pattern)

Do **NOT** fetch full remote history (disk / time). Shared slot overwrite is intentional.

1. Feishu: SKIP
2. Add remote if needed: `git remote add delivery-xygty git@github.com:xy-gty/xy-gty.git` (or reuse origin)
3. Push sealed product HEAD only:
   `git -C <product> push delivery-xygty HEAD:main --force`
   (or `git push origin HEAD:main --force` if origin is already xy-gty)
4. Verify: `git ls-remote git@github.com:xy-gty/xy-gty.git HEAD` == local `0c9a46961a1b19bfe70c2b422641a07dd3d2a2e7`
5. Write evidence/github-push.txt with local_commit == remote_head
6. Skip publish-run-context if disk tight
7. MAP Status/Verdict ready; finish; stop

No UITEST. No accept rewind. product/ name OK.
