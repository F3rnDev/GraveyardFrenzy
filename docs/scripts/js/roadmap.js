function jumpToCurrent() {
    document.getElementById("-progress").scrollIntoView({behavior: 'smooth'});
}

function selectStep(step)
{
    //search if step is already selected
    if (step.classList.contains('roadmap-selected'))
    {
        step.classList.remove('roadmap-selected');        
        return;
    }

    var roadmapItems = document.querySelectorAll('.roadmap-item');
    roadmapItems.forEach((item) => {
        item.classList.remove('roadmap-selected');
    });

    roadmapItems = document.querySelectorAll('.roadmap-item-progress');
    roadmapItems.forEach((item) => {
        item.classList.remove('roadmap-selected');
    });

    step.classList.add('roadmap-selected');

    const roadmap = document.querySelector('.roadmap');

    if ('ResizeObserver' in window) {
        const observer = new ResizeObserver(() => {
            updateRoadmapLineDone();
        });

        observer.observe(roadmap);
    }
}

function updateRoadmapLineDone() {
  const roadmap = document.querySelector('.roadmap');
  const roadmapItems = document.querySelectorAll('.roadmap-content');
  const roadmapLineDone = document.querySelector('.roadmap-line-done');

  if (roadmapItems && roadmapLineDone) {
    let lastDoneIndex = -1;

    roadmapItems.forEach((el, index) => {
      if (el.classList.contains('done')) {
        lastDoneIndex = index;
      }
    });

    if (lastDoneIndex !== -1) {
      const lastDoneEl = roadmapItems[lastDoneIndex];
      const roadmapTop = roadmap.getBoundingClientRect().top;
      const doneBottom = lastDoneEl.getBoundingClientRect().bottom;
      const height = doneBottom - roadmapTop  + 50;

      roadmapLineDone.style.height = `${height}px`;
    }
  }
}