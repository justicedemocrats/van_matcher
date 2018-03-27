import Papa from "papaparse";

var max_rows = 10;

function getFile() {
  return document.getElementById("file-upload").files[0];
}

function clearPreviewTable(field) {
  var table = document.getElementById(`table-${field}`);
  table.style.display = "none";
  table.querySelector(".table-body").innerHTML = "";
}

function appendPreviewRow(field, value) {
  var table = document.getElementById(`table-${field}`);
  table.style.display = "block";
  var html = `<td>${value}</td>`;
  var el = document.createElement("tr");
  el.innerHTML = html;
  table.querySelector(".table-body").appendChild(el);
}

Array.from(document.querySelectorAll(".col-selector")).map(function(
  col_selector
) {
  console.log(col_selector);
  col_selector.onchange = function(ev) {
    var field = this.name.replace("col_", "");

    clearPreviewTable(field);

    var rows_seen = 0;
    var file = getFile();

    if (file) {
      Papa.parse(file, {
        header: false,
        step: function(results, parser) {
          if (rows_seen > 0) {
            appendPreviewRow(field, results.data[0][ev.target.value - 1]);
          }

          rows_seen++;

          if (rows_seen > max_rows) {
            parser.pause();
          }
        }
      });
    }
  };
});
