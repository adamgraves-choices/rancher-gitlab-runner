FROM gitlab/gitlab-runner

COPY entrypoint.sh /

VOLUME /etc/gitlab-runner/

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gitlab-runner"]
