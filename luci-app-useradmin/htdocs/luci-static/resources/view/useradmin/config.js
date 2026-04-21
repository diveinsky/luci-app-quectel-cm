'use strict';
'require dom';
'require rpc';
'require ui';
'require view';

var callFileExec = rpc.declare({
	object: 'file',
	method: 'exec',
	params: [ 'command', 'params', 'env' ],
	expect: { '': { code: 0, stdout: '', stderr: '' } },
	timeout: 30
});

function parseUsers(output) {
	return (output || '').trim().split(/\n/).filter(Boolean).map(function(line) {
		var parts = line.split('\t');

		return {
			username: parts[0] || '',
			rpcd: parts[1] === 'yes'
		};
	});
}

return view.extend({
	loadUsers: function() {
		return callFileExec('/usr/bin/luci-useradmin.sh', [ '--list' ], {}).then(function(res) {
			return parseUsers((res.stdout || '') + (res.stderr || ''));
		});
	},

	updateUsersSection: function(usersSection, users, refreshUsers, setResult) {
		dom.content(usersSection, [
			E('h3', _('Existing Users')),
			this.renderUserTable(users, usersSection, refreshUsers, setResult)
		]);
	},

	waitForUserState: function(username, shouldExist) {
		var self = this;
		var attempts = 30;

		function check() {
			return self.loadUsers().then(function(users) {
				var exists = users.some(function(user) { return user.username === username; });

				if (exists === shouldExist)
					return users;

				if (--attempts <= 0)
					throw new Error(_('Timed out waiting for user state to update.'));

				return new Promise(function(resolve) {
					window.setTimeout(resolve, 2000);
				}).then(check);
			});
		}

		return check();
	},

	renderUserTable: function(users, usersSection, refreshUsers, setResult) {
		var self = this;

		if (!users.length) {
			return E('div', { 'class': 'cbi-section-descr' },
				_('No shell-disabled LuCI users have been created yet.'));
		}

		return E('table', { 'class': 'table cbi-section-table' }, [
			E('tr', { 'class': 'tr table-titles' }, [
				E('th', { 'class': 'th' }, _('Username')),
				E('th', { 'class': 'th' }, _('LuCI Login Entry')),
				E('th', { 'class': 'th' }, _('Actions'))
			])
		].concat(users.map(L.bind(function(user) {
				return E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td' }, user.username),
					E('td', { 'class': 'td' }, user.rpcd ? _('Present') : _('Missing')),
					E('td', { 'class': 'td' }, [
						E('button', {
							'class': 'btn cbi-button cbi-button-remove',
							'click': ui.createHandlerFn(this, function() {
								if (!confirm(_('Delete user "%s"?').format(user.username)))
									return;

								setResult(_('Deleting user...'), false);

								return callFileExec('/usr/bin/luci-useradmin.sh', [ '--delete-async', user.username ], {}).then(function(res) {
									var output = ((res.stdout || '') + (res.stderr || '')).trim();
									
									if (res.code !== 0) {
										setResult(output || _('Failed to start user deletion.'), true);
										return;
									}

									setResult(_('Deletion started. Waiting for user to disappear from the list...'), false);

									return refreshUsers().then(function() {
										return self.waitForUserState(user.username, false);
									}).then(function(users) {
										setResult(_('User deleted successfully. Restart rpcd to apply LuCI login changes.'), false);
										self.updateUsersSection(usersSection, users, refreshUsers, setResult);
									}).catch(function(err) {
										setResult(_('User deletion started, but list refresh timed out: %s').format(err.message || err), true);
									});
								}).catch(function(err) {
									setResult(_('Failed to delete user: %s').format(err.message || err), true);
								});
							})
						}, [ _('Delete') ])
					])
				]);
			}, this))));
	},

	render: function() {
		var username = E('input', {
			'class': 'cbi-input-text',
			'type': 'text'
		});
		var password = E('input', {
			'class': 'cbi-input-password',
			'type': 'password'
		});
		var confirmation = E('input', {
			'class': 'cbi-input-password',
			'type': 'password'
		});
		var result = E('div', { 'class': 'cbi-section-descr' });
		var usersSection = E('div', { 'class': 'cbi-section' }, [
			E('h3', _('Existing Users')),
			E('div', { 'class': 'cbi-section-descr' }, _('Loading user list...'))
		]);
		var self = this;

		function setResult(text, isError) {
			dom.content(result, E('p', {
				'style': isError ? 'color:#c00;' : ''
			}, text));
		}

		function refreshUsers() {
			return self.loadUsers().then(function(users) {
				self.updateUsersSection(usersSection, users, refreshUsers, setResult);
			}).catch(function(err) {
				dom.content(usersSection, [
					E('h3', _('Existing Users')),
					E('div', { 'class': 'cbi-section-descr', 'style': 'color:#c00;' },
						_('Failed to load user list: %s').format(err.message || err))
				]);
			});
		}

		return refreshUsers().then(function() {
			return E('div', { 'class': 'cbi-map' }, [
				E('h2', _('LuCI User Administration')),
				E('div', { 'class': 'cbi-map-descr' },
					_('Create a LuCI login user and a system account with shell access disabled.')),
				E('div', { 'class': 'cbi-section' }, [
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' }, _('Username')),
						E('div', { 'class': 'cbi-value-field' }, [ username ])
					]),
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' }, _('Password')),
						E('div', { 'class': 'cbi-value-field' }, [ password ])
					]),
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' }, _('Confirmation')),
						E('div', { 'class': 'cbi-value-field' }, [ confirmation ])
					]),
					E('div', { 'class': 'cbi-page-actions' }, [
						E('button', {
							'class': 'btn cbi-button cbi-button-apply',
							'click': ui.createHandlerFn(self, function() {
								var user = username.value.trim();
								var pass = password.value;
								var confirm = confirmation.value;

								if (!user || !pass) {
									setResult(_('Username and password are required.'), true);
									return;
								}

								if (pass !== confirm) {
									setResult(_('Password confirmation does not match.'), true);
									return;
								}

								setResult(_('Creating user...'), false);

								return callFileExec('/usr/bin/luci-useradmin.sh', [ '--create-async', user, pass ], {}).then(function(res) {
									var output = ((res.stdout || '') + (res.stderr || '')).trim();
									
									if (res.code !== 0) {
										setResult(output || _('Failed to start user creation.'), true);
										return;
									}

									setResult(_('Creation started. Waiting for user to appear in the list...'), false);

									username.value = '';
									password.value = '';
									confirmation.value = '';

									return refreshUsers().then(function() {
										return self.waitForUserState(user, true);
									}).then(function(users) {
										setResult(_('User created successfully. Restart rpcd to enable the new LuCI login.'), false);
										self.updateUsersSection(usersSection, users, refreshUsers, setResult);
									}).catch(function(err) {
										setResult(_('User creation started, but list refresh timed out: %s').format(err.message || err), true);
									});
								}).catch(function(err) {
									setResult(_('Failed to create user: %s').format(err.message || err), true);
								});
							})
						}, [ _('Create user') ])
					]),
					result
				]),
				usersSection
			]);
		});
	}
});
