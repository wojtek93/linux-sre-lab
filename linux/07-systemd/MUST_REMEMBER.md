PID 1 → systemd

.service → service definition

systemctl start → start now

systemctl enable → start on boot

daemon-reload → reload unit files

journalctl -u service -f → live logs

Restart=always

Restart=on-failure

ExecStart=

WantedBy=multi-user.target
