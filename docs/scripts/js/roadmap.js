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
}