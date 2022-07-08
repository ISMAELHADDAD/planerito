import Sortable from "sortablejs";

export const InitSortable = {
  mounted() {
    const callback = (list) => {
      this.pushEvent("sort", { list: list });
    };
    init(this.el, callback);
  },
};

const init = (sortableList, callback) => {
  const listId = sortableList.dataset.listId;

  const sortable = new Sortable(sortableList, {
    group: "shared",
    animation: 150,
    ghostClass: "opacity-0",
    dragClass: "bg-blue-400",
    chosenClass: "bg-blue-400",
    onSort: (evt) => {
      let ids = [];
      const nodeList = sortableList.querySelectorAll("[data-sortable-id]");
      for (let i = 0; i < nodeList.length; i++) {
        const idObject = {
          id: nodeList[i].dataset.sortableId,
          date: listId,
          sort_order: i,
        };
        ids.push(idObject);
      }
      callback(ids);
    },
  });
};
