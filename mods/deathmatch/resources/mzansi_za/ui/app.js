const params = new URLSearchParams(window.location.search);
const type = params.get('type') || 'bank';

const screen = document.getElementById('screen');

function renderBankUI() {
    screen.innerHTML = '<iframe src="bank.html" style="width: 100%; height: 420px; border: none;"></iframe>';
}

function renderMdtUI() {
    screen.innerHTML = '<iframe src="mdt.html" style="width: 100%; height: 420px; border: none;"></iframe>';
}

function renderPropertyUI() {
    screen.innerHTML = '<iframe src="property.html" style="width: 100%; height: 420px; border: none;"></iframe>';
}

function renderRegisterUI() {
    screen.innerHTML = '<iframe src="register.html" style="width: 100%; height: 420px; border: none;"></iframe>';
}

if (type === 'bank') {
    renderBankUI();
} else if (type === 'mdt') {
    renderMdtUI();
} else if (type === 'property') {
    renderPropertyUI();
} else {
    renderRegisterUI();
}

window.addEventListener('message', function (event) {
    if (event.data && event.data.type === 'mzansi:createCharacter') {
        window.parent.postMessage({ type: 'mzansi:registrationResult', success: true, result: 'Character submitted' }, '*');
    }
    if (event.data && event.data.type === 'mzansi:bank:action') {
        window.parent.postMessage({ type: 'mzansi:bank:action', action: event.data.action, amount: event.data.amount }, '*');
    }
    if (event.data && event.data.type === 'mzansi:mdt:search') {
        window.parent.postMessage({ type: 'mzansi:mdt:search', query: event.data.query }, '*');
    }
});
