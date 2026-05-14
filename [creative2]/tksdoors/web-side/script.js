let doorToDeleteId = null;
let doorToDeleteRow = null;

window.addEventListener('message', function (event) {
    let data = event.data;
    if (data.action === "open" || data.type === "open") {
        document.getElementById("container").style.display = "flex";
        document.getElementById("back").style.display = "block";
        loadTable(data.doors || []);
    } else if (data.action === "openCreateModal") {
        document.getElementById("container").style.display = "none"; // Oculta a tabela pra você ver o modal sobre a porta
        document.getElementById("newDoorPerm").value = "";

        let selectType = document.getElementById("newDoorType");
        if (data.hasDouble === true) {
            selectType.innerHTML = '<option value="normal">Normal (1 Porta)</option><option value="dupla" selected>Dupla (Detectamos a 2ª porta)</option><option value="portao">Portão</option>';
        } else {
            selectType.innerHTML = '<option value="normal">Normal (1 Porta)</option><option value="dupla">Dupla (Tentar detectar)</option><option value="portao">Portão</option>';
        }

        document.getElementById("createModal").style.display = "flex";
        document.getElementById("createModal").style.zIndex = "9999";
        document.getElementById("back").style.display = "block";
    }
});

function loadTable(doors) {
    const list = document.getElementById("doorList");
    list.innerHTML = "";

    doors.forEach(door => {
        let isGateText = door.isGate ? '<span style="color:#f1c40f">Portão</span>' : 'Porta';
        list.innerHTML += `
            <tr>
                <td>#${door.id}</td>
                <td>${door.dist}m</td>
                <td>${isGateText}</td>
                <td>
                    <input type="text" class="perm-input" id="perm-${door.id}" value="${door.perm || ''}">
                </td>
                <td>
                    <button class="btn btn-tp" onclick="teleport(${door.x}, ${door.y}, ${door.z})" title="Ir até"><i class="fas fa-map-marker-alt"></i></button>
                    <button class="btn btn-save" onclick="savePerm(${door.id})" title="Salvar Permissão"><i class="fas fa-save"></i></button>
                    <button class="btn btn-del" onclick="openDeleteModal(${door.id}, this)" title="Deletar"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `;
    });
}

function openDeleteModal(id, btn) {
    doorToDeleteId = id;
    doorToDeleteRow = btn.closest('tr');
    document.getElementById("deleteDoorId").innerText = id;
    document.getElementById("deleteModal").style.display = "flex";
}

function closeDeleteModal() {
    doorToDeleteId = null;
    doorToDeleteRow = null;
    document.getElementById("deleteModal").style.display = "none";
}

function confirmDeleteDoor() {
    if (doorToDeleteId !== null) {
        fetch("https://" + GetParentResourceName() + "/deleteDoor", {
            method: "POST",
            body: JSON.stringify({ id: doorToDeleteId })
        });
        if (doorToDeleteRow) {
            doorToDeleteRow.remove();
        }
        closeDeleteModal();
    }
}

function openCreateModal() {
    closeUI();
    fetch("https://" + GetParentResourceName() + "/startCreateMode", { method: 'POST' });
}

function closeCreateModal() {
    document.getElementById("createModal").style.display = "none";
    document.getElementById("back").style.display = "none";
    fetch("https://" + GetParentResourceName() + "/closeUI", { method: 'POST' });
}

function confirmCreateDoor() {
    let perm = document.getElementById("newDoorPerm").value;
    let type = document.getElementById("newDoorType").value;

    fetch("https://" + GetParentResourceName() + "/createDoor", {
        method: "POST",
        body: JSON.stringify({
            perm: perm,
            isDouble: (type === "dupla"),
            isGate: (type === "portao")
        })
    });

    closeCreateModal();
    closeUI(); // Fecha UI para ver se funcionou
}

function filterDoors() {
    let input = document.getElementById("searchInput").value.toUpperCase();
    let table = document.querySelector(".table-container table");
    let tr = table.getElementsByTagName("tr");

    for (let i = 1; i < tr.length; i++) {
        let tdId = tr[i].getElementsByTagName("td")[0];
        let tdPermInput = tr[i].querySelector(".perm-input");
        let tdPerm = tdPermInput ? tdPermInput.value.toUpperCase() : "";

        if (tdId || tdPerm) {
            let txtId = tdId.textContent || tdId.innerText;
            if (txtId.toUpperCase().indexOf(input) > -1 || tdPerm.indexOf(input) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
}

function closeUI() {
    document.getElementById("container").style.display = "none";
    document.getElementById("back").style.display = "none";
    document.getElementById("createModal").style.display = "none";
    document.getElementById("deleteModal").style.display = "none";
    fetch("https://" + GetParentResourceName() + "/closeUI", { method: 'POST' });
}

function teleport(x, y, z) {
    fetch("https://" + GetParentResourceName() + "/teleport", {
        method: "POST",
        body: JSON.stringify({ x: x, y: y, z: z })
    });
}

function savePerm(id) {
    let permValue = document.getElementById("perm-" + id).value;
    fetch("https://" + GetParentResourceName() + "/updatePerm", {
        method: "POST",
        body: JSON.stringify({ id: id, perm: permValue })
    });
}

document.onkeyup = function (data) {
    if (data.key == "Escape") {
        closeUI();
    }
};